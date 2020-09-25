# frozen_string_literal: true

require_relative 'mutations'

module Osso
  module GraphQL
    module Types
      class MutationType < BaseObject
        field :configure_identity_provider, mutation: Mutations::ConfigureIdentityProvider, null: true
        field :create_identity_provider, mutation: Mutations::CreateIdentityProvider
        field :create_enterprise_account, mutation: Mutations::CreateEnterpriseAccount
        field :create_oauth_client, mutation: Mutations::CreateOauthClient
        field :delete_enterprise_account, mutation: Mutations::DeleteEnterpriseAccount
        field :delete_identity_provider, mutation: Mutations::DeleteIdentityProvider
        field :delete_oauth_client, mutation: Mutations::DeleteOauthClient
        field :set_redirect_uris, mutation: Mutations::SetRedirectUris
        field :regenerate_oauth_credentials, mutation: Mutations::RegenerateOauthCredentials
        field :update_app_config, mutation: Mutations::UpdateAppConfig

        def self.authorized?(_object, _context)
          # mutations are prevented from executing with ready? so
          # its a bit odd that this hides it
          true
        end
      end
    end
  end
end
