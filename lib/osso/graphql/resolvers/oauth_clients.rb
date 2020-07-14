# frozen_string_literal: true

module Osso
  module GraphQL
    module Resolvers
      class OAuthClients < ::GraphQL::Schema::Resolver
        type [Types::OAuthClient], null: true

        def resolve
          return Osso::Models::OauthClient.all if context[:scope] == :admin
        end
      end
    end
  end
end
