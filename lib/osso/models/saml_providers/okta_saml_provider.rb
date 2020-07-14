# frozen_string_literal: true

module Osso
  module Models
    # Subclass for Okta IDP instances
    class OktaSamlProvider < Models::IdentityProvider
      def name
        'Okta'
      end

      def saml_options
        attributes.slice(
          'domain',
          'idp_cert',
          'idp_sso_target_url',
        ).merge(
          issuer: id,
          name_identifier_format: NAME_FORMAT,
        ).symbolize_keys
      end
    end
  end
end
