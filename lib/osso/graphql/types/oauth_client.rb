# frozen_string_literal: true

require 'graphql'

module Osso
  module GraphQL
    module Types
      class OauthClient < Types::BaseObject
        description 'An OAuth client used to consume Osso SAML users'
        implements ::GraphQL::Types::Relay::Node

        global_id_field :gid
        field :id, ID, null: false
        field :name, String, null: false
        field :client_id, String, null: false
        field :client_secret, String, null: false
        field :redirect_uris, [Types::RedirectUri], null: true

        def client_id
          object.identifier
        end

        def client_secret
          object.secret
        end

        def self.authorized?(_object, context)
          admin_authorized?(context)
        end
      end
    end
  end
end
