# frozen_string_literal: true

module Osso
  module Error
    class SamlConfigError < Base
      def message
        'Something went wrong with your SAML configuration.'
      end
    end

    class InvalidACSURLError < SamlConfigError
      def message
        'The ACS URL specfied in your Identity Provider configuration is malformed.'
      end
    end
  end
end
