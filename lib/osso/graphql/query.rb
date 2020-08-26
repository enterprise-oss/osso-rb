# frozen_string_literal: true

module Osso
  module GraphQL
    module Types
      class QueryType < ::GraphQL::Schema::Object
        field :enterprise_accounts, null: true, resolver: Resolvers::EnterpriseAccounts do
          argument :sort_column, String, required: false
          argument :sort_order, String, required: false
        end

        field :enterprise_account, null: true, resolver: Resolvers::EnterpriseAccount do
          argument :domain, String, required: true
        end

        field :oauth_clients, null: true, resolver: Resolvers::OAuthClients

        field(
          :identity_provider,
          Types::IdentityProvider,
          null: true,
          resolve: ->(_obj, args, _context) { Osso::Models::IdentityProvider.find(args[:id]) },
        ) do
          argument :id, ID, required: true
        end

        field(
          :app_config,
          Types::AppConfig,
          null: false,
          resolve: ->(_obj, _args, _context) { Osso::Models::AppConfig.find },
        )

        field(
          :oauth_client,
          Types::OauthClient,
          null: true,
          resolve: ->(_obj, args, _context) { Osso::Models::OauthClient.find(args[:id]) },
        ) do
          argument :id, ID, required: true
        end

        field(
          :current_user,
          Types::AdminUser,
          null: false,
          resolve: ->(_obj, _args, context) { context.to_h },
        )
      end
    end
  end
end
