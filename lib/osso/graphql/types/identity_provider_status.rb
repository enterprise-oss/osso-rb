# frozen_string_literal: true

module Osso
  module GraphQL
    module Types
      class IdentityProviderStatus < BaseEnum
        value('Pending', value: 'pending')
        value('Configured', value: 'configured')
        value('Active', value: 'active')
        value('Error', value: 'error')
      end
    end
  end
end
