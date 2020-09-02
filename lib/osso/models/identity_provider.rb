# frozen_string_literal: true

module Osso
  module Models
    # Base class for SAML Providers
    class IdentityProvider < ActiveRecord::Base
      belongs_to :enterprise_account
      belongs_to :oauth_client
      has_many :users
      before_save :set_status
      validate :sso_cert_valid

      def name
        service.titlecase
      end

      def saml_options
        {
          domain: domain,
          idp_sso_target_url: sso_url,
          idp_cert: sso_cert,
          issuer: domain,
        }
      end

      def assertion_consumer_service_url
        [
          root_url,
          'auth',
          'saml',
          id,
          'callback',
        ].join('/')
      end

      alias acs_url assertion_consumer_service_url

      def set_status
        return if status != 'PENDING'

        self.status = 'CONFIGURED' if sso_url && sso_cert
      end

      def active!
        update(status: 'ACTIVE')
      end

      def error!
        update(status: 'ERROR')
      end

      def root_url
        return "https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com" if ENV['HEROKU_APP_NAME']

        ENV.fetch('BASE_URL')
      end

      def sso_cert_valid
        return if sso_cert.blank?

        OpenSSL::X509::Certificate.new([
          "-----BEGIN CERTIFICATE-----\n",
          sso_cert,
          "\n-----END CERTIFICATE-----\n",
        ].join)

      rescue OpenSSL::X509::CertificateError
        errors.add(:sso_cert, 'x509 Certificate is malformed')
      end
    end
  end
end

# == Schema Information
#
# Table name: identity_providers
#
#  id                    :uuid             not null, primary key
#  service               :string
#  domain                :string           not null
#  sso_url               :string
#  sso_cert              :text
#  enterprise_account_id :uuid
#  oauth_client_id       :uuid
#  status                :enum             default("PENDING")
#  created_at            :datetime
#  updated_at            :datetime
#
# Indexes
#
#  index_identity_providers_on_domain                 (domain)
#  index_identity_providers_on_enterprise_account_id  (enterprise_account_id)
#  index_identity_providers_on_oauth_client_id        (oauth_client_id)
#
