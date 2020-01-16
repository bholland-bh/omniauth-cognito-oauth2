# Omniauth::Cognito::Oauth2

Oauth2 strategy for AWS Cognito

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-cognito-oauth2'
```
Then `bundle install`

## Setup

You will need:

 - an AWS Cognito user pool
 - a domain setup for your user pool
 - an environment variable on your dev machine which contains your domain - something like `COGNITO_USER_POOL_DOMAIN=https://your_user_pool_domain.auth.us-west-1.amazoncognito.com` for your variable, and then `ENV['COGNITO_USER_POOL_DOMAIN']` in your code
 - an App Client set up for your user pool, exposing at least `openid` and `email`. (Don't set up your user pool client application with a 'Client Secret' because at the moment they don't work and don't allow you to authenticate.)
 - an environment variable on your dev machine which contains your App Client ID - something like `COGNITO_CLIENT_ID=your_app_client_id` for your variable, and then `ENV['COGNITO_CLIENT_ID']` in your code

## Usage

Here's an example for adding the middleware to a Rails app in `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cognito_oauth2, ENV['COGNITO_CLIENT_ID'], scope: [:openid, :email],
    setup: lambda{ |env|
      env['omniauth.strategy'].options[:client_options].site = ENV['COGNITO_USER_POOL_DOMAIN']
    }
end
```

Since Cognito has many different client sites, we are using a lambda to dynamically set the site that you wish to authenticate against. This will be the domain you have setup for your user pool. These is more info in the Authorization Code Grant section in the AWS docs [here](https://aws.amazon.com/blogs/mobile/understanding-amazon-cognito-user-pool-oauth-2-0-grants/).

You can now access the OmniAuth Cognito OAuth2 URL: `/auth/cognito_oauth2`

## Usage (Devise)

First define your application id and secret in `config/initializers/devise.rb`.

```ruby
config.omniauth :cognito_oauth2, ENV['COGNITO_CLIENT_ID'], scope: [:openid, :email],
  setup: lambda{ |env|
    env['omniauth.strategy'].options[:client_options].site = ENV['COGNITO_USER_POOL_DOMAIN']
  }
```

NOTE: If you are using this gem with devise with above snippet in `config/initializers/devise.rb` then do not create `config/initializers/omniauth.rb` which will conflict with devise configurations.

Then add the following to 'config/routes.rb' so the callback routes are defined.

```ruby
devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
```

Make sure your model is omniauthable. Generally this is "/app/models/user.rb"

```ruby
devise :omniauthable, omniauth_providers: [:cognito_oauth2]
```

Then make sure your callbacks controller is setup.

```ruby
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def cognito_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Cognito") if is_navigational_format?
    else
      # session["devise.cognito_data"] = request.env["omniauth.auth"].except("extra", "provider") # causes cookie overflow - consider creating a session table in your DB to store large session info https://stackoverflow.com/questions/9473808/cookie-overflow-in-rails-application
      set_flash_message(:alert, :failure, kind: "Cognito")
      redirect_to new_user_session_path
    end
  end

  def failure
    redirect_to new_user_session_path
  end
end
```

and bind to or create the user

```ruby
def self.from_omniauth(auth)
  where(email: auth.info.email, uid: auth.uid, provider: "cognito_oauth2").first_or_create! do |user|
    user.email = auth.info.email
    user.password = Devise.friendly_token[0,20]
    user.provider = "cognito_oauth2"
    user.uid = auth.uid
  end
end
```

Devise will automatically generate a link for you on their default signup/login view, but you can make your own like this if necessary:

```erb
<%= link_to "Sign in with Cognito", user_cognito_oauth2_omniauth_authorize_path %>

<%# Devise prior 4.1.0: %>
<%= link_to "Sign in with Cognito", user_omniauth_authorize_path(:cognito_oauth2) %>
```

An overview is available at https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview

## Configuration

You can configure several options, which you pass in to the `provider` method via a hash:

* `scope`: A comma-separated list of permissions you want to request from the user. See the [AWS Cognito docs](https://aws.amazon.com/blogs/mobile/understanding-amazon-cognito-user-pool-oauth-2-0-grants/) for a full list of available permissions. Caveats:
  * The `openid` and `email` scopes are used by default. By defining your own `scope`, you override these defaults.

* `redirect_uri`: Override the redirect_uri used by the gem.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://gitlab.com/felixfortis/omniauth-cognito-oauth2.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
