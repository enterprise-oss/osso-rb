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

          if customer.destroy
            Osso::Analytics.capture(email: context[:email], event: self.class.name.demodulize, properties: args)
            return response_data(enterprise_account: nil) 
          end
          

          response_error(customer.errors)
        end

        def domain(**args)
          enterprise_account(**args).domain
        end
      end
    end
  end
end
