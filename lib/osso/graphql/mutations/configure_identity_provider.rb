# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class ConfigureIdentityProvider < BaseMutation
        null false
        argument :id, ID, required: true
        argument :service, Types::IdentityProviderService, required: false
        argument :sso_url, String, required: false
        argument :sso_cert, String, required: false

        field :identity_provider, Types::IdentityProvider, null: false
        field :errors, [String], null: false

        def resolve(id:, **args)
          provider = Osso::Models::IdentityProvider.find(id)

          return unauthorized unless authorized?
          return response_data(identity_provider: provider) if provider.update(args)

          response_error(errors: provder.errors.messages)
        end
      end
    end
  end
end
