# frozen_string_literal: true

require 'jwt'
require 'omniauth/strategies/oauth2'
require 'uri'

module OmniAuth
  module Strategies
    class CognitoOauth2 < OmniAuth::Strategies::OAuth2
    end

    class Error < StandardError; end
  end
end
