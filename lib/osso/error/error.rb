# frozen_string_literal: true

module Osso
  module Error
    class Base < StandardError
      def docs_url
        nil
      end
    end
  end
end

require_relative 'account_configuration_error'
require_relative 'missing_saml_attribute_error'
require_relative 'oauth_error'
require_relative 'saml_config_error'
