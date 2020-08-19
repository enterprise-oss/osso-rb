# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class DeleteEnterpriseAccount < BaseMutation
        null false

        argument :id, ID, required: true

        field :enterprise_account, Types::EnterpriseAccount, null: true
        field :errors, [String], null: false

        def enterprise_account(id)
          @enterprise_account ||= Osso::Models::EnterpriseAccount.find(id)
        end

        def resolve(id:)
          return response_data(enterprise_account: nil) if enterprise_account(id).destroy

          response_error(errors: enterprise_account(id).errors.full_messages)
        end

        def ready?(id:, **args)
          return true if super(**args)

          domain_ready?(enterprise_account(id).domain)
        end
      end
    end
  end
end
