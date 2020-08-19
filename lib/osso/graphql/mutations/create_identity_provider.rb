# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class CreateIdentityProvider < BaseMutation
        null false

        argument :enterprise_account_id, ID, required: true
        argument :service, Types::IdentityProviderService, required: false

        field :identity_provider, Types::IdentityProvider, null: false
        field :errors, [String], null: false

        def resolve(enterprise_account_id:, service: nil)
          customer = enterprise_account(enterprise_account_id)
          identity_provider = customer.identity_providers.build(
            service: service,
            domain: customer.domain,
            oauth_client_id: customer.oauth_client_id,
          )

          return response_data(identity_provider: identity_provider) if identity_provider.save

          response_error(errors: identity_provider.errors.full_messages)
        end

        def ready?(enterprise_account_id:, **args)
          return true if super(**args)

          domain_ready?(enterprise_account(enterprise_account_id).domain)
        end

        def enterprise_account(id)
          @enterprise_account ||= Osso::Models::EnterpriseAccount.find(id)
        end
      end
    end
  end
end
