# frozen_string_literal: true

require 'graphql'

module Osso
  module GraphQL
    module Types
      class BaseObject < ::GraphQL::Schema::Object
        connection_type_class GraphQL::Types::BaseConnection

        field :created_at, ::GraphQL::Types::ISO8601DateTime, null: false
        field :updated_at, ::GraphQL::Types::ISO8601DateTime, null: false

        def self.admin_authorized?(context)
          context[:scope] == 'admin'
        end

        def self.internal_authorized?(context)
          %w[admin internal].include?(context[:scope])
        end

        def self.enterprise_authorized?(context, domain)
          return false unless domain

          context[:email].split('@')[1] == domain
        end

        def self.authorized?(object, context)
          # we first receive the payload object as a hash, but can depend on the
          # return type to hide the actual objects non-admins shouldn't see
          return true if object.instance_of?(Hash)

          internal_authorized?(context) || enterprise_authorized?(context, object&.domain)
        end
      end
    end
  end
end
