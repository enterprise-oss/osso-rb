# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class DeleteRedirectUri < BaseMutation
        null false

        argument :id, ID, required: true

        field :oauth_client, Types::OauthClient, null: true
        field :errors, [String], null: false

        def resolve(id:)
          redirect_uri = Osso::Models::RedirectUri.find(id)

          oauth_client = redirect_uri.oauth_client

          redirect_uri.destroy

          if redirect_uri.primary
            oauth_client.redirect_uris.first&.update(primary: true)
          end

          return response_data(oauth_client: oauth_client.reload) if redirect_uri.destroy

          response_error(errors: redirect_uri.errors.full_messages)
        end

        def ready?(*)
          return true if context[:scope] == :admin

          raise ::GraphQL::ExecutionError, 'Only admin users may mutate OauthClients'
        end
      end
    end
  end
end
