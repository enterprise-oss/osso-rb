# frozen_string_literal: true

module Osso
  module GraphQL
    module Types
      class IdentityProviderStatus < BaseEnum
        value('Pending', value: 'PENDING')
        value('Configured', value: 'CONFIGURED')
        value('Active', value: 'ACTIVE')
        value('Error', value: 'ERROR')
      end
    end
  end
end
