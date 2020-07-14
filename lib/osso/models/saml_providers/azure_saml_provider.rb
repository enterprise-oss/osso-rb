# frozen_string_literal: true

module Osso
  module Models
    # Subclass for Azure / ADFS IDP instances
    class AzureSamlProvider < Models::IdentityProvider
      def name
        'Azure'
      end

      def saml_options
        attributes.slice(
          'domain',
          'idp_cert',
          'idp_sso_target_url',
        ).merge(
          issuer: "id:#{id}",
        ).symbolize_keys
      end
    end
  end
end
