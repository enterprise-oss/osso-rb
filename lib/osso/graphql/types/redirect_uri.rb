# frozen_string_literal: true

require 'graphql'

module Osso
  module GraphQL
    module Types
      class RedirectUri < Types::BaseObject
        description 'An allowed redirect URI for an OauthClient'

        field :id, ID, null: false
        field :uri, String, null: false
        field :primary, Boolean, null: false

        def self.authorized?(_object, context)
          context[:scope] == 'admin'
        end
      end
    end
  end
end
