class Authorization::BasicHttpProvider
  def initialize(auth_config)
    @auth_config = auth_config
  end

  def authenticate(controller)
    if (user = check_basic_auth(controller))
      @current_user = user
    else
      controller.request_http_basic_authentication
    end
  end

private

  def check_basic_auth(controller)
    controller.authenticate_with_http_basic do |username, password|
      username if BCrypt::Password.new(@auth_config['users'][username]) == password
    end
  end
end
