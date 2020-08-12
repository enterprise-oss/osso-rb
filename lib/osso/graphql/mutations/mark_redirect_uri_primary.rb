# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class MarkRedirectUriPrimary < BaseMutation
        null false

        argument :id, ID, required: true

        field :oauth_client, Types::OauthClient, null: true
        field :errors, [String], null: false

        def resolve(id:)
          redirect_uri = Osso::Models::RedirectUri.find(id)
          oauth_client = redirect_uri.oauth_client

          oauth_client.redirect_uris.update(primary: false)
          redirect_uri.update(primary: true)

          response_data(oauth_client: oauth_client.reload)
        rescue StandardError => e
          response_error(errors: e.message)
        end

        def ready?(*)
          return true if context[:scope] == :admin

          raise ::GraphQL::ExecutionError, 'Only admin users may mutate OauthClients'
        end
      end
    end
  end
end
