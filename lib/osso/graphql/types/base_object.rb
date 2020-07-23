# frozen_string_literal: true

require 'graphql'

module Osso
  module GraphQL
    module Types
      class BaseObject < ::GraphQL::Schema::Object
        field :created_at, ::GraphQL::Types::ISO8601DateTime, null: false
        field :updated_at, ::GraphQL::Types::ISO8601DateTime, null: false
      end
    end
  end
end
