# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class DeleteEnterpriseAccount < BaseMutation
        null false

        argument :id, ID, required: true

        field :enterprise_account, Types::EnterpriseAccount, null: true
        field :errors, [String], null: false

        def resolve(id:)
          enterprise_account = Osso::Models::EnterpriseAccount.find(id)

          return response_data(enterprise_account: nil) if enterprise_account.destroy

          response_error(errors: enterprise_account.errors.full_messages)
        end

        def ready?(id:)
          return true if context[:scope] == :admin

          domain = account_domain(id)

          return true if domain == context[:scope]

          raise ::GraphQL::ExecutionError, "This user lacks the scope to mutate records belonging to #{domain}"
        end
      end
    end
  end
end
