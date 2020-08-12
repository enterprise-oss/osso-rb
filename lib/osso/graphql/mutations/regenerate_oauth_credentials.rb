# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class RegenerateOauthCredentials < BaseMutation
        null false

        argument :id, ID, required: true

        field :oauth_client, Types::OauthClient, null: false
        field :errors, [String], null: false

        def resolve(id:)
          oauth_client = Osso::Models::OauthClient.find(id)
          oauth_client.generate_secrets
          
          return response_data(oauth_client: oauth_client) if oauth_client.save
        
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
