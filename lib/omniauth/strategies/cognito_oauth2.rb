# frozen_string_literal: true

require 'jwt'
require 'omniauth/strategies/oauth2'
require 'uri'

module OmniAuth
  module Strategies
    class CognitoOauth2 < OmniAuth::Strategies::OAuth2
      option :name, 'cognito_oauth2'

      option :client_options, {
        :site => "https://bookingbug-dev.auth.eu-west-1.amazoncognito.com",
        :authorize_url => "/oauth2/authorize",
        :token_url => "/oauth2/token"
      }

      uid { raw_info["id"] }

      info do
        {
          :email => raw_info["email"]
          # and anything else you want to return to your API consumers
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/api/v1/me.json').parsed
      end

      def callback_url
        options[:redirect_uri] || (full_host + script_name + callback_path)
      end
    end

    class Error < StandardError; end
  end
end
