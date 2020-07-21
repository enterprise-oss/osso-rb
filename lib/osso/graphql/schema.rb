# frozen_string_literal: true

require 'graphql'
require_relative 'types'
require_relative 'resolvers'
require_relative 'mutation'
require_relative 'query'

GraphQL::Relay::BaseConnection.register_connection_implementation(
  ActiveRecord::Relation,
  GraphQL::Relay::RelationConnection,
)

module Osso
  module GraphQL
    class Schema < ::GraphQL::Schema
      use ::GraphQL::Pagination::Connections
      query Types::QueryType
      mutation Types::MutationType

      def self.id_from_object(object, _type_definition = nil, _query_ctx = nil)
        GraphQL::Schema::UniqueWithinType.encode(object.class.name, object.id)
      end

      def self.object_from_id(id, _query_ctx = nil)
        class_name, item_id = GraphQL::Schema::UniqueWithinType.decode(id)
        Object.const_get(class_name).find(item_id)
      end

      def self.resolve_type(_type, obj, _ctx)
        case obj
        when Osso::Models::EnterpriseAccount
          Types::EnterpriseAccount
        when Osso::Models::IdentityProvider
          Types::IdentityProvider
        else
          raise("Unexpected object: #{obj}")
        end
      end

      def self.unauthorized_object(error)
        raise ::GraphQL::ExecutionError, "An object of type #{error.type.graphql_name} was hidden due to permissions"
      end
    end
  end
end
