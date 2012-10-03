# GraphAPI
GraphAPI is a Ruby Gem containing some common tasks to help manage Facebook users using the Facebook Graph API.

## Usage

Here is how to use it.

### Add it to your Gemfile

    gem 'sprock-assets', require 'sprock_assets'

### Set up your Facebook Appications constants

You will have to configure the module before using it. Here is an example setup.

    module GraphAPI
      # Public: Required constant used for Facebook private application secret.
      APP_SECRET = '124ca2a483f12723cafa7a5da33a3492'
      # Public: Required constant used for Facebook private application client ID.
      CLIENT_ID  = '234513432316919'
      # Public: Reqired constant used for Facebook call back URL when receiving the Facebook connect code param.
      CALLBACK_URL = nil
      # Public: Required constant used for setting Facebook application requirements.
      ACCESS_SCOPE = [:offline_access, :email, :user_photos, :user_location, :user_about_me]
      # Public: Required constant used for setting the fields pulled for.
      USER_FIELDS = [:id, :picture, :name, :gender, :link, :email, :verified, :bio]
    end

### Add it to your Application

Once configured you will be able to use any of its functions in your application. Here is basic example using Sinatra.

    get '/facebook_login' do
      redirect FaceGraph::auth_url
    end

    get '/facebook_auth' do
      @facebook_user = GraphAPI::fetch_user(params[:code])
      @photo = GraphAPI::fetch_photo(@facebook_user['access_token'])
      render :signed_in
    end

### License
WTFPL &copy; 2012 Nick Barth
