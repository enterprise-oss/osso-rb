# frozen_string_literal: true

require_relative 'mutations'

module Osso
  module GraphQL
    module Types
      class MutationType < BaseObject
        field :configure_identity_provider, mutation: Mutations::ConfigureIdentityProvider
        field :create_identity_provider, mutation: Mutations::CreateIdentityProvider
        field :set_identity_provider, mutation: Mutations::SetSamlProvider
      end
    end
  end
end
