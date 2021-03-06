# GraphAPI [![Build Status](https://secure.travis-ci.org/nickbarth/GraphAPI.png?branch=master)](https://travis-ci.org/nickbarth/GraphAPI)
GraphAPI is a Ruby Gem created to simplifiy and help manage authentication using
the Facebook Graph API.

## Usage

Here is how to use it.

### Add it to your Gemfile

    gem 'graph-api', require: 'graph_api'

### Set up your Facebook Appications constants

You will have to configure the gem before using it. Here is an example setup.

    GraphAPI.config do
      app_secret   '124ca2a483f12723cafa7a5da33a3492'      # The Facebook Application Secret
      client_id    '234513432316919'                       # The Facebook Application Id
      callback_url 'http://example.com/facebook_callback/' # URI for receiving the Facebook code param
      logout_url   'http://example.com/logout/'            # URI to redirect to when logging out
      access_scope [:offline_access, :email, :user_photos] # The Facebook application requirements
      user_fields  [:id, :picture, :name, :gender, :email] # The user fields pulled for
    end

Visit https://developers.facebook.com/apps to register your Facebook application
or checkout https://developers.facebook.com/docs/reference/api/user/ for a list
of user fields and permissions.

### Add it to your Application

Once configured you will be able to use GraphAPI to retrieve any Facebook
user fields in your application. Here is basic example using Sinatra.

    get '/facebook_login' do
      redirect GraphAPI.auth_url
    end

    get '/facebook_callback' do
      @facebook_user = GraphAPI.new(false, params[:code])
      session[:auth_token] = @facebook_user.auth_token
      render :signed_in
    end

    get '/profile'
      @facebook_user = GraphAPI.new(session[:auth_token])
      logger.info "User #{@facebook_user.name} viewed their profile."
      render :profile
    end

### License
WTFPL &copy; 2012 Nick Barth
