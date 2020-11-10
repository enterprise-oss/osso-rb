# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class CreateIdentityProvider < BaseMutation
        null false

        argument :enterprise_account_id, ID, required: true
        argument :service, Types::IdentityProviderService, required: false
        argument :oauth_client_id, String, required: true

        field :identity_provider, Types::IdentityProvider, null: false
        field :errors, [String], null: false

        def resolve(service: nil, enterprise_account_id:, oauth_client_id:)
          customer = enterprise_account(enterprise_account_id: enterprise_account_id)

          identity_provider = customer.identity_providers.build(
            service: service,
            domain: customer.domain,
            oauth_client_id: oauth_client_id,
          )

          return response_data(identity_provider: identity_provider) if identity_provider.save

          response_error(identity_provider.errors)
        end

        def domain(enterprise_account_id:, **args)
          enterprise_account(enterprise_account_id: enterprise_account_id)&.domain
        end

        def enterprise_account(enterprise_account_id:)
          @enterprise_account ||= Osso::Models::EnterpriseAccount.find(enterprise_account_id)
        end
      end
    end
  end
end
