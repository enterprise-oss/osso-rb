# frozen_string_literal: true

require 'cgi'
require 'omniauth'
require 'omniauth-multi-provider'
require 'omniauth-saml'

module Osso
  class Auth < Sinatra::Base
    include AppConfig
    register Sinatra::Namespace

    UUID_REGEXP =
      /[0-9a-f]{8}-[0-9a-f]{3,4}-[0-9a-f]{4}-[0-9a-f]{3,4}-[0-9a-f]{12}/.
        freeze

    use OmniAuth::Builder do
      OmniAuth::MultiProvider.register(
        self,
        provider_name: 'saml',
        identity_provider_id_regex: UUID_REGEXP,
        path_prefix: '/auth/saml',
        callback_suffix: 'callback',
      ) do |identity_provider_id, _env|
        Models::IdentityProvider.
          not_pending.
          find(identity_provider_id).
          saml_options
      rescue StandardError => e
        Raven.capture_exception(e) if defined?(Raven)
        {}
      end
    end

    OmniAuth.config.on_failure = proc do |env|
      OmniAuth::FailureEndpoint.new(env).redirect_to_failure
    end

    namespace '/auth' do
      get '/failure' do
        # ??? invalid ticket, warden throws, ugh

        # confirmed:
        # - a valid but wrong cert will throw here
        #   (OneLogin::RubySaml::ValidationError, Fingerprint mismatch)
        #   but an _invalid_ cert is not caught. we do validate certs on
        #   configuration, so this may be ok
        #
        # - a valid but wrong ACS URL will throw here. the urls
        #   are pretty complex, but it has come up
        #
        # - specifying the wrong "recipient" in your IDP. Only OL so far
        #   (OneLogin::RubySaml::ValidationError, The response was received
        #    at vcardme.com instead of
        #    http://localhost:9292/auth/saml/e54a9a92-b4b5-4ea5-b0e3-b1423eb20b76/callback)

        @error = Osso::Error::SamlConfigError.new
        erb :error
      end
      # Enterprise users are sent here after authenticating against
      # their Identity Provider. We find or create a user record,
      # and then create an authorization code for that user. The user
      # is redirected back to your application with this code
      # as a URL query param, which you then exchange for an access token.
      post '/saml/:provider_id/callback' do
        redirect_uri = SamlHandler.perform(
          auth_hash: env['omniauth.auth'],
          provider_id: params[:provider_id],
          session: session,
        )

        redirect(redirect_uri)
      rescue Osso::Error::Base => e
        @error = e
        erb :error
      end
    end
  end
end
