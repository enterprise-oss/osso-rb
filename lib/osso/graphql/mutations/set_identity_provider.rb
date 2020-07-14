# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class SetSamlProvider < BaseMutation
        null false

        argument :provider, Types::IdentityProviderService, required: true
        argument :id, ID, required: true

        field :identity_provider, Types::IdentityProvider, null: false
        field :errors, [String], null: false

        def resolve(provider:, id:)
          identity_provider = Osso::Models::IdentityProvider.find(id)
          identity_provider.service = provider
          identity_provider.save!
          {
            identity_provider: identity_provider,
            errors: [],
          }
        end
      end
    end
  end
end
