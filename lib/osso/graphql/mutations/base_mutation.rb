# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class BaseMutation < ::GraphQL::Schema::RelayClassicMutation
        object_class Types::BaseObject
        input_object_class Types::BaseInputObject

        def response_data(data)
          data.merge(errors: [])
        end

        def response_error(errors)
          raise ::GraphQL::ExecutionError.new(
            'Mutation error',
            extensions: {
              'errors' => field_errors(errors),
            },
          )
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

        def ready?(**args)
          return true if internal_ready?

          return true if domain_ready?(args[:domain] || domain(**args))

          raise ::GraphQL::ExecutionError, 'This user lacks the permission to make the requested changes'
        end

        def admin_ready?
          context[:scope] == 'admin'
        end

        def internal_ready?
          return true if admin_ready?

          context[:scope] == 'internal'
        end

        def domain_ready?(domain)
          context[:email].split('@')[1] == domain
        end

        def account_domain(id)
          return false unless id

          Osso::Models::EnterpriseAccount.find(id)&.domain
        end

        def provider_domain(id)
          return false unless id

          Osso::Models::IdentityProvider.find(id)&.domain
        end
      end
    end
  end
end
