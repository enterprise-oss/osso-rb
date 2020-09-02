# frozen_string_literal: true

require 'graphql'

module Osso
  module GraphQL
    module Types
      class Error < Types::BaseObject
        description 'A mutation error'

        field :attribute, String, null: false
        field :message, String, null: false

        def self.authorized?(_object, _context)
          true
        end
      end
    end
  end
end
