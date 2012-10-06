# GraphAPI
GraphAPI is a Ruby Gem containing some common tasks to help manage Facebook users using the Facebook Graph API.

## Usage

Here is how to use it.

### Add it to your Gemfile

    gem 'graph-api', require 'graph_api'

### Set up your Facebook Appications constants

You will have to configure the module before using it. Here is an example setup.

    GraphAPI.config app_secret:   '124ca2a483f12723cafa7a5da33a3492'      # The Facebook Application Secret
                    client_id:    '234513432316919'                       # The Facebook Client ID
                    callback_url: 'http://example.com/facebook_callback/' # URI for receiving the Facebook code param
                    access_scope: [:offline_access, :email, :user_photos] # The Facebook application requirements
                    user_fields:  [:id, :picture, :name, :gender, :email] # The user fields pulled for

### Add it to your Application

Once configured you will be able to use any of its functions in your application. Here is basic example using Sinatra.

    get '/facebook_login' do
      redirect FaceGraph.auth_url
    end

    get '/facebook_auth' do
      @facebook_user = GraphAPI.fetch_user(params[:code])
      @photo = GraphAPI.fetch_photo(@facebook_user['access_token'])
      render :signed_in
    end

### License
WTFPL &copy; 2012 Nick Barth
