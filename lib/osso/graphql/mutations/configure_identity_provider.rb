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

        def resolve(**args)
          provider = identity_provider(**args)

          return response_data(identity_provider: provider) if provider.update(args)

          response_error(errors: provider.errors.messages)
        end

        def domain(**args)
          identity_provider(**args)&.domain
        end

        def identity_provider(id:, **_args)
          @identity_provider ||= Osso::Models::IdentityProvider.find(id)
        end
      end
    end
  end
end
