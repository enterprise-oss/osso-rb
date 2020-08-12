# frozen_string_literal: true

require_relative 'mutations'

module Osso
  module GraphQL
    module Types
      class MutationType < BaseObject
        field :add_redirect_uris_to_oauth_client, mutation: Mutations::AddRedirectUrisToOauthClient, null: false
        field :configure_identity_provider, mutation: Mutations::ConfigureIdentityProvider, null: true
        field :create_identity_provider, mutation: Mutations::CreateIdentityProvider
        field :create_enterprise_account, mutation: Mutations::CreateEnterpriseAccount
        field :create_oauth_client, mutation: Mutations::CreateOauthClient
        field :delete_enterprise_account, mutation: Mutations::DeleteEnterpriseAccount
        field :delete_oauth_client, mutation: Mutations::DeleteOauthClient
        field :delete_redirect_uri, mutation: Mutations::DeleteRedirectUri
        field :mark_redirect_uri_primary, mutation: Mutations::MarkRedirectUriPrimary
        field :regenerate_oauth_credentials, mutation: Mutations::RegenerateOauthCredentials
      end
    end
  end
end
