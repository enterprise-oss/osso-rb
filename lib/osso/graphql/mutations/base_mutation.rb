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

        def response_error(error)
          error.merge(data: nil)
        end

        def ready?(**_args)
          return true if context[:scope] == 'admin'

          # domain ||= account_domain(enterprise_account_id) || provider_domain(identity_provider_id)
          # return true if domain == context[:scope]

          # # raise ::GraphQL::ExecutionError, "This user lacks the scope to mutate records belonging to #{args[:domain]}"
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
