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
        field :delete_oauth_client, mutation: Mutations::DeleteOauthClient
      end
    end
  end
end
