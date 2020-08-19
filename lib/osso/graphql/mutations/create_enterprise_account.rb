# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class CreateEnterpriseAccount < BaseMutation
        null false

        argument :domain, String, required: true
        argument :name, String, required: true
        argument :oauth_client_id, ID, required: false

        field :enterprise_account, Types::EnterpriseAccount, null: false
        field :errors, [String], null: false

        def resolve(**args)
          enterprise_account = Osso::Models::EnterpriseAccount.new(args)
          enterprise_account.oauth_client_id ||= context[:oauth_client_id]

          return response_data(enterprise_account: enterprise_account) if enterprise_account.save

          response_error(errors: enterprise_account.errors.full_messages)
        end

        def ready?(domain: nil, **_args)
          return true if %w[admin internal].include?(context[:scope])
          return true if context[:scope] == 'end-user' &&
            context[:email].split('@')[1] == domain

          false
        end
      end
    end
  end
end
