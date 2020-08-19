# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class DeleteEnterpriseAccount < BaseMutation
        null false

        argument :id, ID, required: true

        field :enterprise_account, Types::EnterpriseAccount, null: true
        field :errors, [String], null: false

        def enterprise_account(id:, **_args)
          @enterprise_account ||= Osso::Models::EnterpriseAccount.find(id)
        end

        def resolve(**args)
          customer = enterprise_account(**args)

          return response_data(enterprise_account: nil) if customer.destroy

          response_error(errors: customer.errors.full_messages)
        end

        def domain(**args)
          enterprise_account(**args).domain
        end
      end
    end
  end
end
