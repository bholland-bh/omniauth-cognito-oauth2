# frozen_string_literal: true

require 'jwt'
require 'omniauth/strategies/oauth2'
require 'uri'

module OmniAuth
  module Strategies
    # Standard requirements for implementing Oauth2
    class CognitoOauth2 < OmniAuth::Strategies::OAuth2
      option :name, 'cognito_oauth2'

      option  :client_options,
              authorize_url: '/oauth2/authorize',
              token_url: '/oauth2/token'

      uid { raw_info['sub'] }

      info do
        {
          email: raw_info['email']
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/oauth2/userInfo').parsed
      end

      def callback_url
        options[:redirect_uri] || (full_host + script_name + callback_path)
      end
    end

    class Error < StandardError; end
  end
end
