# frozen_string_literal: true

module Osso
  module GraphQL
    module Resolvers
      class EnterpriseAccount < BaseResolver
        type Types::EnterpriseAccount, null: false

        def resolve(args)
          Osso::Models::EnterpriseAccount.find_by(domain: args[:domain])
        end
      end
    end
  end
end
