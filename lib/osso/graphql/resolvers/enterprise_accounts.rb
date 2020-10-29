# frozen_string_literal: true

module Osso
  module GraphQL
    module Resolvers
      class EnterpriseAccounts < BaseResolver
        type Types::EnterpriseAccount.connection_type, null: true

        def resolve(sort_column: nil, sort_order: nil, search: nil)
          return Array(Osso::Models::EnterpriseAccount.find_by(domain: context_domain)) unless internal_authorized?

          accounts = Osso::Models::EnterpriseAccount
          accounts = accounts.where('domain ilike ? OR name ilike ?', "%#{search}%", "%#{search}%") if search
          accounts = accounts.order(sort_column.underscore => sort_order_sym(sort_order)) if sort_column && sort_order

          accounts.all
        end

        def sort_order_sym(order_string)
          order_string == 'ascend' ? :asc : :desc
        end
      end
    end
  end
end
