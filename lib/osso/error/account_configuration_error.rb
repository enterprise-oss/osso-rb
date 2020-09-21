# frozen_string_literal: true

module Osso
  module Error
    class AccountConfigurationError < Base; end

    class MissingConfiguredIdentityProvider < AccountConfigurationError
      def initialize(domain: 'The requested domain')
        @domain = domain
      end

      def message
        "#{@domain} has no configured Identity Provider. " \
          'SAML configuartion must be finalized before a user ' \
          'for this domain can sign in with SSO.'
      end
    end
  end
end
