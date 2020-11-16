# frozen_string_literal: true

module Osso
  module GraphQL
    module Types
      class IdentityProviderService < BaseEnum
        value('AZURE', 'Microsoft Azure Identity Provider', value: 'AZURE')
        value('GOOGLE', 'Google SAML Identity Provider', value: 'GOOGLE')
        value('OKTA', 'Okta Identity Provider', value: 'OKTA')
        value('ONELOGIN', 'OneLogin Identity Provider', value: 'ONELOGIN')
        value('PING', 'PingID Identity Provider', value: 'PING')
      end
    end
  end
end
