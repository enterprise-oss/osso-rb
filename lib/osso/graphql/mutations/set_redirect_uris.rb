# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class SetRedirectUris < BaseMutation
        null false

        argument :id, ID, required: true
        argument :redirect_uris, [Types::RedirectUrisInput], required: true

        field :oauth_client, Types::OauthClient, null: true
        field :errors, [String], null: false

        def resolve(id:, redirect_uris:)
          oauth_client = Osso::Models::OauthClient.find(id)

          update_existing(oauth_client, redirect_uris)
          create_new(oauth_client, redirect_uris)

          response_data(oauth_client: oauth_client.reload)
        rescue StandardError => e
          response_error(errors: e)
        end

        def ready?(*)
          return true if context[:scope] == :admin

          raise ::GraphQL::ExecutionError, 'Only admin users may mutate OauthClients'
        end

        def update_existing(oauth_client, redirect_uris)
          oauth_client.redirect_uris.each do |redirect|
            updating_index = redirect_uris.index{ |incoming| incoming[:id] == redirect.id }

            if updating_index
              updating = redirect_uris.delete_at(updating_index)
              redirect.update(updating.to_h)
              next
            end

            redirect.destroy
          end
        end

        def create_new(oauth_client, redirect_uris)
          redirect_uris.map do |uri|
            oauth_client.redirect_uris.create(uri.to_h.without(:id))
          end
        end
      end
    end
  end
end
