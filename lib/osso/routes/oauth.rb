# frozen_string_literal: true

require 'rack/oauth2'

module Osso
  class Oauth < Sinatra::Base
    include AppConfig
    register Sinatra::Namespace

    namespace '/oauth' do # rubocop:disable Metrics/BlockLength
      # Send your users here in order to being an authentication
      # flow. This flow follows the authorization grant oauth
      # spec with one exception - you must also pass the domain
      # of the user who wants to sign in. If the sign in request
      # is valid, the user is redirected to their Identity Provider.
      # Once they complete IdP login, they will be returned to the
      # redirect_uri with an authorization code parameter.
      get '/authorize' do
        identity_providers = find_providers(params)

        validate_oauth_request(env)

        redirect "/auth/saml/#{identity_providers.first.id}" if identity_providers.one?

        @providers = identity_providers.not_pending
        return erb :multiple_providers if @providers.count > 1

        raise Osso::Error::MissingConfiguredIdentityProvider.new(domain: params[:domain])
      rescue Osso::Error::Base => e
        @error = e
        erb :error
      end

      # Exchange an authorization code for an access token.
      # In addition to the authorization code, you must include all
      # paramaters required by OAuth spec: redirect_uri, client ID,
      # and client secret
      post '/token' do
        Rack::OAuth2::Server::Token.new do |req, res|
          client = Models::OauthClient.find_by!(identifier: req.client_id)
          req.invalid_client! if client.secret != req.client_secret

          code = Models::AuthorizationCode.find_by_token!(params[:code])
          req.invalid_grant! if code.redirect_uri != req.redirect_uri

          requested = session.delete(:osso_oauth_requested)

          res.access_token = code.create_access_token(requested: requested).to_bearer_token
        end.call(env)
      end

      # Use the access token to request a profile for the user who
      # just logged in. Access tokens are short-lived.
      get '/me' do
        json Models::AccessToken.
          includes(:user).
          valid.
          find_by_token!(params[:access_token]).
          user
      end
    end

    private

    def find_providers(params)
      if params[:email]
        user = find_user(email: params[:email])
        return [user.identity_provider] if user
      end

      find_account(
        domain: params[:domain] || params[:email].split('@')[1],
        client_identifier: params[:client_id],
      ).identity_providers
    end

    def find_account(domain:, client_identifier:)
      Osso::Models::EnterpriseAccount.
        includes(:identity_providers).
        joins(:oauth_client).
        find_by!(
          domain: domain,
          oauth_clients: { identifier: client_identifier },
        )
    rescue ActiveRecord::RecordNotFound
      raise Osso::Error::NoAccountForOAuthClientError.new(domain: params[:domain])
    end

    def find_user(email:)
      Osso::Models::User.
        includes(:identity_provider).
        find_by(email: email)
    end

    def find_client(identifier)
      @client ||= Models::OauthClient.find_by!(identifier: identifier)
    rescue ActiveRecord::RecordNotFound
      raise Osso::Error::InvalidOAuthClientIdentifier
    end

    def validate_oauth_request(env) # rubocop:disable Metrics/AbcSize
      Rack::OAuth2::Server::Authorize.new do |req, _res|
        client = find_client(req[:client_id])
        session[:osso_oauth_redirect_uri] = req.verify_redirect_uri!(client.redirect_uri_values)
        session[:osso_oauth_state] = params[:state]
        session[:osso_oauth_requested] = { domain: params[:domain], email: params[:email] }
      end.call(env)
    rescue Rack::OAuth2::Server::Authorize::BadRequest
      raise Osso::Error::InvalidRedirectUri.new(redirect_uri: params[:redirect_uri])
    end
  end
end
