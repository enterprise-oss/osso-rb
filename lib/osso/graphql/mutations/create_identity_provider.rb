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
          enterprise_account = Osso::Models::EnterpriseAccount.find(enterprise_account_id)
          identity_provider = enterprise_account.identity_providers.build(
            enterprise_account_id: enterprise_account_id,
            service: service,
            domain: enterprise_account.domain,
          )

          return response_data(identity_provider: identity_provider) if identity_provider.save

          response_error(errors: identity_provider.errors.full_messages)
        end
      end
    end
  end
end
