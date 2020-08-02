# frozen_string_literal: true

module Osso
  module GraphQL
    module Types
      class BaseConnection < ::GraphQL::Types::Relay::BaseConnection
        field :total_count, Integer, null: false

        def total_count
          object.items&.count
        end
      end
    end
  end
end
