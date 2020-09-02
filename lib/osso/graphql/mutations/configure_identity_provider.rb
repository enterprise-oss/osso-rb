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

          return response_data(identity_provider: provider) if provider.update(args)

          raise ::GraphQL::ExecutionError.new(
            'Mutation error',
            extensions: {
              'errors' => field_errors(provider.errors.messages),
            }
          )
        end

        def domain(**args)
          identity_provider(**args)&.domain
        end

        def identity_provider(id:, **_args)
          @identity_provider ||= Osso::Models::IdentityProvider.find(id)
        end

        def field_errors(errors)
          errors.map do |attribute, messages|
            attribute = attribute.to_s.camelize(:lower)
            {
              attribute: attribute,
              message: messages,
            }
          end
        end
      end
    end
  end
end
