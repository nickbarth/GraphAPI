require 'json'
require 'rest_client'
require 'graph_api/version'

# Public: GraphAPI is a Ruby Gem created to simplifiy and help manage
#         authentication using the Facebook Graph API.
#
# Example:
#
#   get '/facebook_login' do
#     redirect GraphAPI.auth_url
#   end
#
#   get '/facebook_callback' do
#     @facebook_user = GraphAPI.new(params[:code])
#     session[:auth_token] = @facebook_user.auth_token
#     render :signed_in
#   end
#
class GraphAPI
  class << self
    # Public: Required setting used for Facebook private application secret.
    #
    # Example:
    #
    # @app_secret = '124ca2a483f12723cafa7a5da33a3492'
    attr_accessor :app_secret

    # Public: Required setting used for Facebook application Id.
    #
    # Example
    #
    # @client_id  = '234513432316919'
    attr_accessor :client_id

    # Public: Reqired setting used for Facebook call back URL when receiving the Facebook connect code param.
    #
    # Example
    #
    # @callback_url = nil
    attr_accessor :callback_url

    # Public: Required setting used for setting Facebook application requirements.
    #
    # Example
    #
    # @access_scope = [:offline_access, :email, :user_photos, :user_location, :user_about_me]
    attr_accessor :access_scope

    # Public: Required setting used for setting the fields pulled for.
    #
    # Example
    #
    # @user_fields = [:id, :picture, :name, :gender, :link, :email, :verified, :bio]
    attr_accessor :user_fields
  end

  # Public: Method for configuring the setting settings for a nicer syntax.
  #
  # Example:
  #
  # GraphAPI.config app_secret: '124ca2a483f12723cafa7a5da33a3492',
  #                 client_id:  '234513432316919'
  #
  def self.config(settings)
    settings.each do |setting, value|
      self.send("#{setting}=", value)
    end
  end

  # Public: Creates and returns a Facebook Authentication URL based on the supplied settings.
  #
  # callback_url - With @callback_url set to nil setting this parameter will use
  #                the sent callback. This is useful when you're using dynamic
  #                URIs with subdomains.
  def self.auth_url(callback_url=nil)
    "https://graph.facebook.com/oauth/authorize?client_id=#{@client_id}" +
    "&redirect_uri=#{@callback_url or callback_url}" +
    "&scope=#{@access_scope.join(',')}"
  end

  # Public: Requests the Access Token from the Facebook Graph API and returns it as a string.
  #
  # code - The code parameter is the param you receive when the Facebook Graph
  #        API hits your call back URI.
  #
  # callback_url - With @callback_url set to nil setting this parameter will use
  #                the sent callback. This is useful when you're using dynamic
  #                URIs with subdomains.
  def self.fetch_token(code, callback_url=nil)
    RestClient.post('https://graph.facebook.com/oauth/access_token', { client_id:     @client_id,
                                                                       redirect_uri:  (@callback_url or callback_url),
                                                                       client_secret: @app_secret,
                                                                       code:          code
    })[/access_token=(.+?)&/, 1]
  end

  # Creates a request to the Facebook graph API and returns the response.
  #
  # url - The URL of the request begining with a forward slash.
  # access_token - The access token required for making the request on the Facebook users behalf.
  #
  # Returns a parsed JSON array returned from the Facebook service with a format like ['example' => 'some_data'].
  def self.request(url, access_token)
    JSON.parse(RestClient.get "https://graph.facebook.com#{url}&access_token=#{access_token}")
  end

  # Public: Get and set the facebook access token.
  attr_accessor :access_token
  # Public: Get and set a users data based on the current access token.
  attr_accessor :user_data

  # Public: Creates a new Graph API instance.
  #
  # Returns a object representing the current Facebook user with properties
  # specified in the self.class.user_fields hash array.
  def initialize(access_token, code=nil, callback_url=nil)
    @access_token = if not code.nil?
      self.class.fetch_token(code, callback_url)
    else
      access_token
    end
  end

  # Public: Fetches and returns the cover photo src for a Facebook user.
  def photo
    albums = self.class.request('/me/albums?fields=id,cover_photo,type', @access_token)['data']
    photo_id = albums.find{|x| x['type'] == 'profile'}['cover_photo']
    self.class.request("/#{photo_id}/?fields=source", @access_token)['source']
  end

  # Public: Fetches and returns the current thumbnail src for a Facebook user.
  def thumbnail
    self.picture['data']['url']
  end

  # Public: Meta methods for each of the user fields declared.
  #
  # Example:
  #
  #   facebook_user = GraphAPI.new(auth_token) # Creates a new user
  #   puts facebook_user.name                  # Returns the Facebook users full name.
  def method_missing(method, *args, &block)
    user_fields = self.class.user_fields << :picture
    if user_fields.include? method.to_sym
      @user_data ||= self.class.request("/me?fields=#{user_fields.join(',')}", @access_token)
      @user_data[method.to_s]
    else
      super
    end
  end
end
