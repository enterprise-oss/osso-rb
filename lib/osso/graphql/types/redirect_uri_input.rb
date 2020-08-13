# frozen_string_literal: true

require 'graphql'

module Osso
  module GraphQL
    module Types
      class RedirectUrisInput < Types::BaseInputObject
        description 'Attributes for creating or updating a collection of redirect URIs for an Oauth Client'
        argument :id, ID, 'Database ID', required: false
        argument :uri, String, 'URI value', required: true
        argument :primary, Boolean, 'Whether the URI is the primary uri used in IDP initiated login', required: true
      end
    end
  end
end
