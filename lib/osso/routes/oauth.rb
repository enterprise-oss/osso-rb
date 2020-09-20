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
        client = find_client(params[:client_id])
        enterprise = find_account(domain: params[:domain], client_id: client.id)

        validate_oauth_request(env)

        redirect "/auth/saml/#{enterprise.provider.id}" if enterprise.single_provider?

        @providers = enterprise.identity_providers.not_pending
        erb :multiple_providers

      rescue Osso::Error::OAuthError => e
        @error = e
        erb :error
      end

      # Exchange an authorization code for an access token.
      # In addition to the authorization code, you must include all
      # paramaters required by OAuth spec: redirect_uri, client ID,
      # and client secret
      post '/token' do
        Rack::OAuth2::Server::Token.new do |req, res|
          code = Models::AuthorizationCode.
            find_by_token!(params[:code])
          client = Models::OauthClient.find_by!(identifier: req.client_id)
          req.invalid_client! if client.secret != req.client_secret
          req.invalid_grant! if code.redirect_uri != req.redirect_uri
          res.access_token = code.access_token.to_bearer_token
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

    def find_account(domain:, client_id:)
      Models::EnterpriseAccount.
        includes(:identity_providers).
        find_by!(domain: domain, oauth_client_id: client_id)
    rescue ActiveRecord::RecordNotFound
      raise Osso::Error::NoAccountForOAuthClientError
    end

    def find_client(identifier)
      @client ||= Models::OauthClient.find_by!(identifier: identifier)
    rescue ActiveRecord::RecordNotFound
      raise Osso::Error::InvalidOAuthClientIdentifier
    end

    def validate_oauth_request(env)
      Rack::OAuth2::Server::Authorize.new do |req, _res|
        client = find_client(req[:client_id])
        session[:osso_oauth_redirect_uri] = req.verify_redirect_uri!(client.redirect_uri_values)
        session[:osso_oauth_state] = params[:state]
      end.call(env)
    rescue Rack::OAuth2::Server::Authorize::BadRequest
      raise Osso::Error::InvalidRedirectUri
    end
  end
end
