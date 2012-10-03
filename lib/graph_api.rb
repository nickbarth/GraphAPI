require 'json'
# Public: Various methods useful for interfacing with Facebook Graph protocol.
#
# Example:
#
#   get '/facebook_login' do
#     redirect FaceGraph::auth_url
#   end
#
#   get '/facebook_auth' do
#     @facebook_user = GraphAPI::fetch_user(params[:code])
#     @photo = GraphAPI::fetch_photo(@facebook_user['access_token'])
#     render :signed_in
#   end
#
module GraphAPI
  # Public: Required constant used for Facebook private application secret.
  #
  # Example:
  #
  # APP_SECRET = '124ca2a483f12723cafa7a5da33a3492'

  # Public: Required constant used for Facebook private application client ID.
  #
  # Example
  #
  # CLIENT_ID  = '234513432316919'

  # Public: Reqired constant used for Facebook call back URL when receiving the Facebook connect code param.
  #
  # Example
  #
  # CALLBACK_URL = nil

  # Public: Required constant used for setting Facebook application requirements.
  #
  # Example
  #
  # ACCESS_SCOPE = [:offline_access, :email, :user_photos, :user_location, :user_about_me]

  # Public: Required constant used for setting the fields pulled for.
  #
  # Example
  #
  # USER_FIELDS = [:id, :picture, :name, :gender, :link, :email, :verified, :bio]

  # Public: Creates and returns a Facebook Authentication URL based on the supplied constants.
  #
  # callback_url - With CALLBACK_URL set to nil setting this parameter will use
  #                the sent callback. This is useful when you're using dynamic
  #                URIs with subdomains.
  def self.auth_url(callback_url=nil)
    "https://graph.facebook.com/oauth/authorize?client_id=#{CLIENT_ID}" +
    "&redirect_uri=#{CALLBACK_URL or callback_url}" +
    "&scope=#{ACCESS_SCOPE.join(',')}"
  end

  # Public: Requests the Access Token from the Facebook Graph API and returns it as a string.
  #
  # code - The code parameter is the param you receive when the Facebook Graph
  #        API hits your call back URI.
  #
  # callback_url - With CALLBACK_URL set to nil setting this parameter will use
  #                the sent callback. This is useful when you're using dynamic
  #                URIs with subdomains.
  def self.fetch_token(code, callback_url=nil)
    RestClient.get('https://graph.facebook.com/oauth/access_token', { client_id:     CLIENT_ID,
                                                                      redirect_uri:  (CALLBACK_URL or callback_url),
                                                                      client_secret: APP_SECRET,
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

  # Public: Returns a Facebook user array containing the fields set by the
  #         USER_FIELDS constant and the access token for convenience.
  def self.request_user(access_token)
    request("/me?&fields=#{USER_FIELDS.join(',')}", access_token).
      merge('access_token' => access_token)
  end

  # Public: Convenience method for fetching a Facebook user array from the
  #         Facebook token code.
  #
  # callback_url - With CALLBACK_URL set to nil setting this parameter will use
  #                the sent callback. This is useful when you're using dynamic
  #                URIs with subdomains.
  def self.fetch_user(code, callback_url=nil)
    access_token = fetch_token(code, callback_url)
    request_user(access_token)
  end

  # Public: Fetches and returns the cover photo src for a Facebook user.
  #
  # access_token - This method requires an Facebook Authentication token.
  def self.fetch_photo(access_token)
    albums = request('/me/albums?fields=id,cover_photo,type', access_token)['data']
    photo_id = albums.find{|x| x['type'] == 'profile'}['cover_photo']
    request("/#{photo_id}/?fields=source", access_token)['source']
  end

  # Public: Fetches and returns the current thumbnail src for a Facebook user.
  #
  # access_token - This method requires an Facebook Authentication token.
  def self.fetch_thumbnail(access_token)
    request('/me?fields=picture', access_token)['picture']
  end
end
