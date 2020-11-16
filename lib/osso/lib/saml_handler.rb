# frozen_string_literal: true

module Osso
  class SamlHandler
    attr_accessor :session, :provider, :attributes

    def self.perform(**attrs)
      new(attrs).perform
    end

    def initialize(auth_hash:, provider_id:, session:)
      find_provider(provider_id)
      @attributes = auth_hash&.extra&.response_object&.attributes
      @session = session
    end

    def perform
      validate_attributes
      provider.active!
      redirect_uri
    end

    private

    def find_provider(id)
      @provider ||= Models::IdentityProvider.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Osso::Error::InvalidACSURLError
    end

    def validate_attributes
      raise Osso::Error::MissingSamlIdAttributeError unless id_attribute
      raise Osso::Error::MissingSamlEmailAttributeError unless email_attribute
    end

    def id_attribute
      @id_attribute ||= attributes[:id] || attributes[:idp_id]
    end

    def email_attribute
      attributes[:email]
    end

    def user
      @user ||= Models::User.where(
        email: email_attribute,
        idp_id: id_attribute,
      ).first_or_create! do |new_user|
        new_user.enterprise_account_id = provider.enterprise_account_id
        new_user.identity_provider_id = provider.id
      end
    end

    def authorization_code
      @authorization_code ||= user.authorization_codes.create!(
        oauth_client: provider.oauth_client,
        redirect_uri: redirect_uri_base,
        requested: requested_param,
      )
    end

    def redirect_uri
      redirect_uri_base + redirect_uri_querystring
    end

    def redirect_uri_base
      return provider.oauth_client.primary_redirect_uri.uri if valid_idp_initiated_flow

      session[:osso_oauth_redirect_uri]
    end

    def redirect_uri_querystring
      "?code=#{CGI.escape(authorization_code.token)}&state=#{provider_state}"
    end

    def provider_state
      return 'IDP_INITIATED' if valid_idp_initiated_flow

      session.delete(:osso_oauth_state)
    end

    def valid_idp_initiated_flow
      !session[:osso_oauth_redirect_uri] && !session[:osso_oauth_state]
    end

    def requested_param
      @session.delete(:osso_oauth_requested)
    end
  end
end
