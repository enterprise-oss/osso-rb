# frozen_string_literal: true

require 'graphql'

module Osso
  module GraphQL
    module Types
      class AdminUser < Types::BaseObject
        description 'An Admin User of Osso'

        field :id, ID, null: false
        field :email, String, null: false
        field :scope, String, null: false
        field :role, String, null: false
        field :oauth_client_id, ID, null: true

        def self.authorized?(_object, _context)
          true
        end

        def created_at
          12.hours.ago
        end

        def updated_at
          12.hours.ago
        end
      end
    end
  end
end
