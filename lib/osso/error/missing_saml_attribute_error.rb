# frozen_string_literal: true

module Osso
  module Error
    class MissingSamlAttributeError < StandardError; end

    class MissingSamlEmailAttributeError < MissingSamlAttributeError
      def message
        "SAML response does not include the attribute `email`"
      end
    end

    class MissingSamlIdAttributeError < MissingSamlAttributeError
      def message
        "SAML response does not include the attribute `id` or `idp_id`"
      end
    end
  end
end