# frozen_string_literal: true

require 'graphql'

module Osso
  module GraphQL
    module Types
      class EnterpriseAccount < Types::BaseObject
        description 'An Account for a company that wishes to use SAML via Osso'
        implements ::GraphQL::Types::Relay::Node

        field :id, ID, null: false
        field :name, String, null: false
        field :domain, String, null: false
        field :identity_providers, [Types::IdentityProvider], null: true
        field :status, String, null: false
        field :users_count, Integer, null: false

        def status
          'active'
        end

        def identity_providers
          object.identity_providers
        end
      end
    end
  end
end
