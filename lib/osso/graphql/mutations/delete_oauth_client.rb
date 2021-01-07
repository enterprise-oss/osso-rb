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

          if oauth_client.destroy
            Osso::Analytics.capture(email: context[:email], event: self.class.name.demodulize, properties: { id: id })
            return response_data(oauth_client: nil)
          end

          response_error(oauth_client.errors)
        end

        def ready?(*)
          admin_ready?
        end
      end
    end
  end
end
