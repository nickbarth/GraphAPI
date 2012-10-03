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
#     @photo = GraphAPI::fetch_photo(@facebook_user['auth_token'])
#     render :signed_in
#   end
#
module GraphAPI
  # Public: Creates and returns a Facebook Authentication URL based on the supplied constants.
  #
  # callback_url - With CALLBACK_URL set to nil setting this parameter will use
  #                the sent callback. This is useful when you're using dynamic
  #                URIs with subdomains.
  def auth_url(callback_url=nil)
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
  def fetch_token(code, callback_url=nil)
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
  def request(url, access_token)
    JSON.parse(RestClient.get "https://graph.facebook.com#{url}&access_token=#{access_token}")
  end

  # Public: Returns a Facebook user array containing the fields set by the
  #         USER_FIELDS constant and the access token for convenience.
  def request_user(auth_token)
    request("/me?&fields=#{USER_FIELDS.join(',')}", auth_token).
      merge('access_token' => access_token)
  end

  # Public: Convenience method for fetching a Facebook user array from the
  #         Facebook token code.
  #
  # callback_url - With CALLBACK_URL set to nil setting this parameter will use
  #                the sent callback. This is useful when you're using dynamic
  #                URIs with subdomains.
  def fetch_user(code, callback_url=nil)
    auth_token = fetch_token(code, callback_url)
    request_user(auth_token)
  end

  # Public: Fetches and returns the cover photo src for a Facebook user.
  #
  # auth_token - This method requires an Facebook Authentication token.
  def fetch_photo(auth_token)
    albums = request('/me/albums?fields=id,cover_photo,type', auth_token)['data']
    photo_id = albums.find{|x| x['type'] == 'profile' }['cover_photo']
    request("/#{photo_id}/?fields=source", auth_token)['source']
  end

  # Public: Fetches and returns the current thumbnail src for a Facebook user.
  #
  # auth_token - This method requires an Facebook Authentication token.
  def fetch_thumbnail(auth_token)
    request('/me?fields=picture', auth_token)['picture']
  end
end
