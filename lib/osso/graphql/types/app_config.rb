# frozen_string_literal: true

require 'graphql'

module Osso
  module GraphQL
    module Types
      class AppConfig < Types::BaseObject
        description 'Configuration values for your application'

        field :id, ID, null: false
        field :name, String, null: true
        field :logo_url, String, null: true
        field :contact_email, String, null: true

        def self.authorized?(_object, context)
          admin_authorized?(context)
        end
      end
    end
  end
end
