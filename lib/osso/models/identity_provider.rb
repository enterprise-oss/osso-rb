# frozen_string_literal: true

module Osso
  module Models
    # Base class for SAML Providers
    class IdentityProvider < ActiveRecord::Base
      NAME_FORMAT = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
      belongs_to :enterprise_account
      belongs_to :oauth_client
      has_many :users

      before_create :create_enterprise_account

      def name
        service.titlecase
        # raise(
        #   NoMethodError,
        #   '#name must be defined on each provider specific subclass',
        # )
      end

      def saml_options
        attributes.slice(
          'domain',
          'idp_cert',
          'idp_sso_target_url',
        ).symbolize_keys
      end

      # def saml_options
      #   raise(
      #     NoMethodError,
      #     '#saml_options must be defined on each provider specific subclass',
      #   )
      # end

      def assertion_consumer_service_url
        [
          ENV.fetch('BASE_URL'),
          'auth',
          'saml',
          id,
          'callback',
        ].join('/')
      end

      alias acs_url assertion_consumer_service_url

      def create_enterprise_account
        return if enterprise_account_id

        self.enterprise_account = Models::EnterpriseAccount.create(
          domain: domain,
        )
      end
    end
  end
end
