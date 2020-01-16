# frozen_string_literal: true

require File.expand_path(
  File.join('..', 'lib', 'omniauth', 'cognito_oauth2', 'version'),
  __FILE__
)

Gem::Specification.new do |spec|
  spec.name = 'omniauth-cognito-oauth2'
  spec.version = OmniAuth::CognitoOauth2::VERSION
  spec.authors = ['Adam Wenham']
  spec.email = ['adamwenham64@gmail.com']

  spec.summary = 'An Oauth2 strategy for AWS Cognito that plays well both alone and with devise, based on the google-oauth2 version'
  spec.homepage = 'https://gitlab.com/felixfortis/omniauth-cognito-oauth2'
  spec.license = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'omniauth-oauth2', '~> 1.6'

  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 0.78'
end
