# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class DeleteOauthClient < BaseMutation
        null false

        argument :id, ID, required: true

        field :oauth_client, Types::OauthClient, null: true
        field :errors, [String], null: false

        def resolve(id:)
          oauth_client = Osso::Models::OauthClient.find(id)

          return response_data(oauth_client: nil) if oauth_client.destroy

          response_error(errors: oauth_client.errors.full_messages)
        end

        def ready?(*)
          return true if context[:scope] == :admin

          raise ::GraphQL::ExecutionError, 'Only admin users may mutate OauthClients'
        end
      end
    end
  end
end
