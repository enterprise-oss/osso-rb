# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class CreateEnterpriseAccount < BaseMutation
        null false

        argument :domain, String, required: true
        argument :name, String, required: true

        field :enterprise_account, Types::EnterpriseAccount, null: false
        field :errors, [String], null: false

        def resolve(**args)
          enterprise_account = Osso::Models::EnterpriseAccount.new(args)

          if enterprise_account.save
            Osso::Analytics.capture(email: context[:email], event: self.class.name.demodulize, properties: args)
            return response_data(enterprise_account: enterprise_account)
          end

          response_error(enterprise_account.errors)
        end
      end
    end
  end
end
