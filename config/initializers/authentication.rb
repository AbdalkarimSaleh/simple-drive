# This is a simple approach to manage authentication using a hardcoded token from an environment variable.
# Set your Bearer token by defining the following environment variable: AUTH_TOKEN
Rails.application.config.auth_token = ENV['AUTH_TOKEN'] || 'default_token'
