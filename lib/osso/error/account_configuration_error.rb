# frozen_string_literal: true

module Osso
  module Error
    class AccountConfigurationError < StandardError; end

    class MissingConfiguredIdentityProvider < AccountConfigurationError
      def message
        'The requested account has no configured Identity Provider. ' \
          'Before a user for this account can sign in with SSO, you must ' \
          'complete configuration. Review the SSO configuration guides.'
      end
    end
  end
end
