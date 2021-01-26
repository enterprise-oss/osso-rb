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

        field :identity_provider, Types::IdentityProvider, null: true

        def resolve(**args)
          provider = identity_provider(**args)

          if provider.update(args)
            Osso::Analytics.capture(email: context[:email], event: self.class.name.demodulize, properties: args)
            return response_data(identity_provider: provider)
          end

          response_error(provider.errors)
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
