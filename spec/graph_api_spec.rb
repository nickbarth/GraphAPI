require 'spec_helper'

describe GraphAPI do
  before(:each) do
    stub_const('RestClient', Class.new)
  end

  describe '#config' do
    it 'should configuration constants to be set' do
      GraphAPI.config APP_SECRET:   'APP_SECRET',
                      CLIENT_ID:    'CLIENT_ID',
                      CALLBACK_URL: 'CALLBACK_URL',
                      ACCESS_SCOPE: 'ACCESS_SCOPE',
                      USER_FIELDS:  'USER_FIELDS'
      GraphAPI::APP_SECRET.should   == 'APP_SECRET'
      GraphAPI::CLIENT_ID.should    == 'CLIENT_ID'
      GraphAPI::CALLBACK_URL.should == 'CALLBACK_URL'
      GraphAPI::ACCESS_SCOPE.should == 'ACCESS_SCOPE'
      GraphAPI::USER_FIELDS.should  == 'USER_FIELDS'
    end
  end

  describe '#auth_url' do
    before(:each) do
      stub_const('GraphAPI::ACCESS_SCOPE', [:SCOPE1, :SCOPE2])
    end

    it 'should use generate a URI' do
      stub_const('GraphAPI::CALLBACK_URL', nil)
      GraphAPI.auth_url('CALLBACK').should == 'https://graph.facebook.com/oauth/authorize?client_id=CLIENT_ID&redirect_uri=CALLBACK&scope=SCOPE1,SCOPE2'
    end

    it 'should use CLIENT_ID const if avaliable' do
      stub_const('GraphAPI::CALLBACK_URL', 'CALLBACK_URL')
      GraphAPI.auth_url.should == 'https://graph.facebook.com/oauth/authorize?client_id=CLIENT_ID&redirect_uri=CALLBACK_URL&scope=SCOPE1,SCOPE2'
    end
  end

  describe '#fetch_token' do
    it 'should return the access token' do
      stub_const('GraphAPI::CALLBACK_URL', 'CALLBACK_URL')
      RestClient.should_receive(:get).with('https://graph.facebook.com/oauth/access_token', { client_id:     'CLIENT_ID',
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

  describe '#request_user' do
    it 'should return a user' do
      stub_const('GraphAPI::USER_FIELDS', [:FIELD1, :FIELD2])
      GraphAPI.should_receive(:request).with('/me?&fields=FIELD1,FIELD2', 'ACCESS_TOKEN').and_return({})
      GraphAPI.request_user('ACCESS_TOKEN').should == {'access_token' => 'ACCESS_TOKEN'}
    end
  end

  describe '#fetch_user' do
    it 'should return a user' do
      stub_const('GraphAPI::USER_FIELDS', [:FIELD1, :FIELD2])
      stub_const('GraphAPI::CALLBACK_URL', 'CALLBACK_URL')
      GraphAPI.stub(:fetch_token).and_return('ACCESS_TOKEN')
      GraphAPI.should_receive(:request).with('/me?&fields=FIELD1,FIELD2', 'ACCESS_TOKEN').and_return({})
      GraphAPI.fetch_user('CODE').should == {'access_token' => 'ACCESS_TOKEN'}
    end
  end

  describe '#fetch_photo' do
    it 'should return a photo URI' do
      albums_data = {'data' => [{'type' => 'profile', 'cover_photo' => 'PHOTO_ID'}]}
      GraphAPI.should_receive(:request).with('/me/albums?fields=id,cover_photo,type', 'ACCESS_TOKEN').and_return(albums_data)
      GraphAPI.should_receive(:request).with('/PHOTO_ID/?fields=source', 'ACCESS_TOKEN').and_return({'source' => 'PHOTO_URI'})
      GraphAPI.fetch_photo('ACCESS_TOKEN').should == 'PHOTO_URI'
    end
  end

  describe '#fetch_thumbnail' do
    it 'should return a photo URI' do
      GraphAPI.should_receive(:request).with('/me?fields=picture', 'ACCESS_TOKEN').and_return({'picture' => 'PHOTO_URI'})
      GraphAPI.fetch_thumbnail('ACCESS_TOKEN').should == 'PHOTO_URI'
    end
  end
end
