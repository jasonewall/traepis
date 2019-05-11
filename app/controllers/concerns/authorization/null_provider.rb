class Authorization::NullProvider
  def initialize(auth_config = nil); end

  def authenticate(controller); end
end
