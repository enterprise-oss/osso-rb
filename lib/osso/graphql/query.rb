# frozen_string_literal: true

module Osso
  module GraphQL
    module Types
      class QueryType < ::GraphQL::Schema::Object
        field :enterprise_accounts, null: true, resolver: Resolvers::EnterpriseAccounts do
          argument :search, String, required: false
          argument :sort_column, String, required: false
          argument :sort_order, String, required: false
        end

        field :enterprise_account, null: true, resolver: Resolvers::EnterpriseAccount do
          argument :domain, String, required: true
        end

        field :oauth_clients, null: true, resolver: Resolvers::OAuthClients

        field :admin_users, [Types::AdminUser], null: false

        field :app_config, Types::AppConfig, null: false

        field :current_user, Types::AdminUser, null: false

        field :identity_provider, Types::IdentityProvider, null: true do
          argument :id, ID, required: true
        end

        field :oauth_client, Types::OauthClient, null: true do
          argument :id, ID, required: true
        end

        def admin_users
          Osso::Models::Account.all
        end

        def app_config
          Osso::Models::AppConfig.find
        end

        def current_user
          context.to_h
        end

        def identity_provider(id:)
          Osso::Models::IdentityProvider.find(id)
        end

        def oauth_client(id:)
          Osso::Models::OauthClient.find(id)
        end
      end
    end
  end
end
