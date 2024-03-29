# Omniauth::Cognito::Oauth2

[Ruby gem Oauth2 strategy for AWS Cognito](https://rubygems.org/gems/omniauth-cognito-oauth2)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-cognito-oauth2'
```

Then `bundle install`

## Setup

You will need:

 - An AWS Cognito user pool
 - A domain setup for your user pool - once set it will look something like `https://your_user_pool_domain.auth.us-west-1.amazoncognito.com`
 - An App Client set up for your user pool:
   - Callback URL will look something like `http://localhost:3000/users/auth/cognito_oauth2/callback` (standard with a Devise User model)
   - Signout URL will look something like `http://localhost:3000/users/sign_out` (standard with a Devise User model)
   - Check at least the `Authorization code grant` OAuth flow option
   - Check at least the `openid` and `email` OAuth scopes
   - *Don't* set up your App Client with a 'Client Secret' because at the moment they don't work and won't allow you to authenticate.
 - A env/config variable which contains your domain
 - A env/config variable which contains your App Client ID

## Usage

Note: More info at https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview

Here's an example for adding the middleware to a Rails app in `config/initializers/omniauth.rb`:

```ruby
require 'omniauth_cognito_oauth2'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cognito_oauth2, 'MY_COGNITO_CLIENT_ID', scope: [:openid, :email],
    setup: lambda{ |env|
      env['omniauth.strategy'].options[:client_options].site = 'MY_COGNITO_USER_POOL_DOMAIN'
    }
end
```

Since Cognito may have many different Oauth client sites, we are using a lambda to dynamically set the site that you wish to authenticate against. This will be the domain you have setup for your user pool. There is more info in the Authorization Code Grant section in the AWS docs [here](https://aws.amazon.com/blogs/mobile/understanding-amazon-cognito-user-pool-oauth-2-0-grants/).

You can now access the OmniAuth Cognito OAuth2 URL: `/auth/cognito_oauth2`

## Usage (Devise)

First define your client id and user pool domain in `config/initializers/devise.rb`.

```ruby
require 'omniauth_cognito_oauth2'

Devise.setup do |config|
  #...
  config.omniauth :cognito_oauth2, 'MY_COGNITO_CLIENT_ID', scope: [:openid, :email],
    setup: lambda{ |env|
      env['omniauth.strategy'].options[:client_options].site = 'MY_COGNITO_USER_POOL_DOMAIN'
    }
end
```

NOTE: If you use the above snippet in `config/initializers/devise.rb` then do not create `config/initializers/omniauth.rb`, as it will conflict with devise config.

Then add the following to `config/routes.rb` so the callback routes are defined.

```ruby
devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
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

Now add the `omniauthable` and `omniauth_providers` devise options to your user model, along with a method for binding to or creating the user.

```ruby
class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:cognito_oauth2]

#...

  def self.from_omniauth(auth)
    where(email: auth.info.email, uid: auth.uid, provider: "cognito_oauth2").first_or_create! do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.provider = "cognito_oauth2"
      user.uid = auth.uid
    end
  end
end
```

Devise will automatically generate a link for you on their default signup/login view, but you can make your own like this if necessary:

```erb
<%= link_to "Sign in with Cognito", user_cognito_oauth2_omniauth_authorize_path %>

<%# Devise prior 4.1.0: %>
<%= link_to "Sign in with Cognito", user_omniauth_authorize_path(:cognito_oauth2) %>
```

Check `rake routes` if you are unsure.

## Configuration

You can configure several options, which you pass in to the `provider` method via a hash:

* `scope`: A comma-separated list of permissions you want to request from the user. See the [AWS Cognito docs](https://aws.amazon.com/blogs/mobile/understanding-amazon-cognito-user-pool-oauth-2-0-grants/) for a full list of available permissions. Caveats:
  * The `openid` and `email` scopes are needed by default. By defining your own `scope`, you override these defaults

* `redirect_uri`: Override the default redirect_uri used by the gem. The default is to redirect back to your app and then follow the flow from your `cognito_oauth2` callback URL

## Contributing

Bug reports and pull requests are welcome on Gitlab at https://gitlab.com/felixfortis/omniauth-cognito-oauth2.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
