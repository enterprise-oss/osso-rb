# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class DeleteIdentityProvider < BaseMutation
        null false

        argument :id, ID, required: true

        field :identity_provider, Types::IdentityProvider, null: true
        field :errors, [String], null: false

        def resolve(id:)
          identity_provider = Osso::Models::IdentityProvider.find(id)

          return response_data(identity_provider: nil) if identity_provider.destroy

          response_error(identity_provider.errors)
        end
      end
    end
  end
end
