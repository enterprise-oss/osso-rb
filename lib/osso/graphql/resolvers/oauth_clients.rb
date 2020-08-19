# frozen_string_literal: true

module Osso
  module GraphQL
    module Resolvers
      class OAuthClients < BaseResolver
        type [Types::OauthClient], null: true

        def resolve
          Osso::Models::OauthClient.all
        end
      end
    end
  end
end
