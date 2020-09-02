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
          oauth_client.regenerate_secrets!

          return response_data(oauth_client: oauth_client) if oauth_client.save

          response_error(oauth_client.errors)
        end

        def ready?(*)
          admin_ready?
        end
      end
    end
  end
end
