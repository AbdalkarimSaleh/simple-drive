module V1
  class ApplicationController < ActionController::API
    # Use before_action to authenticate requests
    before_action :authenticate
  
    private
  
    # Authenticate using Bearer token from the Authorization header
    def authenticate
      # Extract the Bearer token from the Authorization header
      provided_token = request.headers['Authorization']&.split(' ')&.last
  
      # Compare the provided token with the configured token
      unless provided_token && ActiveSupport::SecurityUtils.secure_compare(provided_token, Rails.application.config.auth_token)
        render json: { error: 'Unauthorized access' }, status: :unauthorized
      end
    end
  end
end