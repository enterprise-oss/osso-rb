# frozen_string_literal: true

module Osso
  module GraphQL
    module Resolvers
      class EnterpriseAccounts < ::GraphQL::Schema::Resolver
        type Types::EnterpriseAccount.connection_type, null: true

        def resolve
          return Osso::Models::EnterpriseAccount.all if context[:scope] == :admin

          Array(Osso::Models::EnterpriseAccount.find_by(domain: context[:scope]))
        end
      end
    end
  end
end
