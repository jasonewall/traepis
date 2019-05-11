class SecureController < ApplicationController
  include Authorization
  before_action :authenticate

private

  def authenticate
    auth_provider.authenticate(self)
  end
end
