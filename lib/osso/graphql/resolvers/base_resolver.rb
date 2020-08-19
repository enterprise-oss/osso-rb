# frozen_string_literal: true

module Osso
  module GraphQL
    module Resolvers
      class BaseResolver < ::GraphQL::Schema::Resolver
        def admin_authorized?
          context[:scope] == 'admin'
        end

        def internal_authorized?
          %w[admin internal].include?(context[:scope])
        end

        def enterprise_authorized?(domain)
          context[:scope] == domain
        end
      end
    end
  end
end
