require 'spec_helper'

describe GraphAPI do
  before(:each) do
    stub_const('RestClient', Class.new)
  end

  describe '#config' do
    it 'should configuration constants to be set' do
      GraphAPI.config do
        app_secret   'APP_SECRET'
        client_id    'CLIENT_ID'
        callback_url 'CALLBACK_URL'
        logout_url   'LOGOUT_URL'
        access_scope 'ACCESS_SCOPE'
        user_fields  'USER_FIELDS'
      end
      GraphAPI.app_secret.should   == 'APP_SECRET'
      GraphAPI.client_id.should    == 'CLIENT_ID'
      GraphAPI.callback_url.should == 'CALLBACK_URL'
      GraphAPI.logout_url.should   == 'LOGOUT_URL'
      GraphAPI.access_scope.should == 'ACCESS_SCOPE'
      GraphAPI.user_fields.should  == 'USER_FIELDS'
    end
  end

  describe '#auth_url' do
    before(:each) do
      GraphAPI.access_scope = [:SCOPE1, :SCOPE2]
    end

    it 'should use generate a URI' do
      GraphAPI.callback_url = nil
      GraphAPI.auth_url('CALLBACK').should == 'https://graph.facebook.com/oauth/authorize?client_id=CLIENT_ID&redirect_uri=CALLBACK&scope=SCOPE1,SCOPE2'
    end

    it 'should use CLIENT_ID const if avaliable' do
      GraphAPI.callback_url = 'CALLBACK_URL'
      GraphAPI.auth_url.should == 'https://graph.facebook.com/oauth/authorize?client_id=CLIENT_ID&redirect_uri=CALLBACK_URL&scope=SCOPE1,SCOPE2'
    end
  end

  describe '#fetch_token' do
    it 'should return the access token' do
      GraphAPI.callback_url = 'CALLBACK_URL'
      RestClient.should_receive(:post).with('https://graph.facebook.com/oauth/access_token', { client_id:     'CLIENT_ID',
                                                                                               redirect_uri:  'CALLBACK_URL',
                                                                                               client_secret: 'APP_SECRET',
                                                                                               code:          'CODE'
      }).and_return('access_token=ACCESS_TOKEN&')
      GraphAPI.fetch_token('CODE').should == 'ACCESS_TOKEN'
    end
  end

  describe '#fetch_token' do
    it 'should return a Ruby Array' do
      RestClient.should_receive(:get).with('https://graph.facebook.com/URL/?&access_token=ACCESS_TOKEN').and_return('[]')
      GraphAPI.request('/URL/?', 'ACCESS_TOKEN').should == []
    end
  end

  describe '#new' do
    context 'with an access_token param' do
      it 'should set the auth_token' do
        GraphAPI.new('ACCESS_TOKEN').access_token.should ==  'ACCESS_TOKEN'
      end
    end

    context 'with a code param' do
      it 'should set the auth_token' do
        GraphAPI.stub(:fetch_token).and_return('ACCESS_TOKEN')
        GraphAPI.new(nil, 'CODE').access_token.should == 'ACCESS_TOKEN'
      end
    end
  end

  context 'Instance' do
    let(:fg_user) { GraphAPI.new('ACCESS_TOKEN') }

    describe '#photo' do
      it 'should return a photo URI' do
        albums_data = {'data' => [{'type' => 'profile', 'cover_photo' => 'PHOTO_ID'}]}
        GraphAPI.should_receive(:request).with('/me/albums?fields=id,cover_photo,type', 'ACCESS_TOKEN').and_return(albums_data)
        GraphAPI.should_receive(:request).with('/PHOTO_ID/?fields=source', 'ACCESS_TOKEN').and_return({'source' => 'PHOTO_URI'})
        fg_user.photo.should == 'PHOTO_URI'
      end
    end

    describe '#thumbnail' do
      it 'should return a photo URI' do
        GraphAPI.user_fields = []
        GraphAPI.should_receive(:request).with('/me?fields=picture', 'ACCESS_TOKEN').and_return({'picture' => {'data' => {'url' => 'PHOTO_URI'}}})
        fg_user.thumbnail.should == 'PHOTO_URI'
      end
    end

    describe '#logout_url' do
      it 'should return the correct logout URL' do
        fg_user.logout_url.should == 'https://www.facebook.com/logout.php?next=LOGOUT_URL&access_token=ACCESS_TOKEN'
      end
    end
  end
end
