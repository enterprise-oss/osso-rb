# frozen_string_literal: true

module Osso
  module Error
    class SamlConfigError < StandardError; end

    class InvalidACSURLError < SamlConfigError
      def message
        'The ACS URL specfied in your Identity Provider configuration is malformed.'
      end
    end
  end
end
