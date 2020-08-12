# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class AddRedirectUrisToOauthClient < BaseMutation
        null false

        argument :oauth_client_id, ID, required: true
        argument :uris, [String], required: true

        field :oauth_client, Types::OauthClient, null: true
        field :errors, [String], null: false

        def resolve(oauth_client_id:, uris:)
          oauth_client = Osso::Models::OauthClient.find(oauth_client_id)

          uris.each do |uri|
            oauth_client.redirect_uris.create(uri: uri)
          end

          unless oauth_client.primary_redirect_uri
            oauth_client.reload.redirect_uris.first.update(primary: true)
          end

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
