# frozen_string_literal: true

module Osso
  module Error
    class MissingSamlAttributeError < Base; end

    class MissingSamlEmailAttributeError < MissingSamlAttributeError
      def message
        'SAML response does not include the attribute `email`. ' \
          "Review the setup guide and check the attributes you're sending from your Identity Provider."
      end
    end

    class MissingSamlIdAttributeError < MissingSamlAttributeError
      def message
        'SAML response does not include the attribute `id` or `idp_id`.' \
          "Review the setup guide and check the attributes you're sending from your Identity Provider."
      end
    end
  end
end
