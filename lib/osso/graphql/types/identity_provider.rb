# frozen_string_literal: true

require 'graphql'

module Osso
  module GraphQL
    module Types
      class IdentityProvider < Types::BaseObject
        description 'Represents a SAML based IDP instance for an EnterpriseAccount'

        field :id, ID, null: false
        field :enterprise_account_id, ID, null: false
        field :service, Types::IdentityProviderService, null: true
        field :domain, String, null: false
        field :acs_url, String, null: false
        field :sso_issuer, String, null: false
        field :sso_url, String, null: true
        field :sso_cert, String, null: true
        field :status, Types::IdentityProviderStatus, null: false
        field :acs_url_validator, String, null: false
        field :oauth_client, Types::OauthClient, null: false
      end
    end
  end
end
