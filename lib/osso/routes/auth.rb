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
        Models::IdentityProvider.find(identity_provider_id).
          saml_options
      end
    end

    namespace '/auth' do # rubocop:disable Metrics/BlockLength
      get '/failure' do
        @error = params[:message]
        erb :error
      end
      # Enterprise users are sent here after authenticating against
      # their Identity Provider. We find or create a user record,
      # and then create an authorization code for that user. The user
      # is redirected back to your application with this code
      # as a URL query param, which you then exchange for an access token.
      post '/saml/:id/callback' do
        provider = Models::IdentityProvider.find(params[:id])
        @oauth_client = provider.oauth_client

        # TODO: PORC for validating attributes
        attributes = env['omniauth.auth']&.
          extra&.
          response_object&.
          attributes

        user = Models::User.where(
          email: attributes[:email],
          idp_id: attributes[:id],
        ).first_or_create! do |new_user|
          new_user.enterprise_account_id = provider.enterprise_account_id
          new_user.identity_provider_id = provider.id
        end

        authorization_code = user.authorization_codes.create!(
          oauth_client: @oauth_client,
          redirect_uri: redirect_uri,
        )
        provider.active!

        redirect(redirect_uri + "?code=#{CGI.escape(authorization_code.token)}&state=#{provider_state}")
      end

      def redirect_uri
        return @oauth_client.primary_redirect_uri.uri if valid_idp_initiated_flow

        session[:osso_oauth_redirect_uri]
      end

      def provider_state
        return @provider_state = 'IDP_INITIATED' if valid_idp_initiated_flow

        session.delete(:osso_oauth_state)
      end

      def valid_idp_initiated_flow
        !session[:osso_oauth_redirect_uri] && !session[:osso_oauth_state]
      end
    end
  end
end
