# frozen_string_literal: true

module Osso
  module Models
    # Base class for SAML Providers
    class IdentityProvider < ActiveRecord::Base
      belongs_to :enterprise_account
      belongs_to :oauth_client
      has_many :users, dependent: :delete_all
      before_save :set_status
      validate :sso_cert_valid

      enum status: { pending: 'PENDING', configured: 'CONFIGURED', active: 'ACTIVE', error: 'ERROR' }

      PEM_HEADER = "-----BEGIN CERTIFICATE-----\n"
      PEM_FOOTER = "\n-----END CERTIFICATE-----"

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

      def acs_url_validator
        Regexp.escape(acs_url)
      end

      def set_status
        self.status = 'configured' if sso_url && sso_cert && pending?
      end

      def active!
        update(status: 'active')
      end

      def error!
        update(status: 'error')
      end

      def root_url
        return "https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com" if ENV['HEROKU_APP_NAME']

        ENV.fetch('BASE_URL')
      end

      def sso_cert_valid
        return if sso_cert.blank?

        has_header_and_footer = sso_cert.match(/#{PEM_HEADER}(?<cert>.*)#{PEM_FOOTER}/m)

        if has_header_and_footer
          OpenSSL::X509::Certificate.new(sso_cert)
          self.sso_cert = has_header_and_footer[:cert]
        else
          OpenSSL::X509::Certificate.new([PEM_HEADER, sso_cert, PEM_FOOTER].join)
        end
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
