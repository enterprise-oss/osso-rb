# frozen_string_literal: true

module Osso
  module Models
    # Base class for Enterprises. This should map one-to-one with
    # your own Account model. Persisting the EnterpriseAccount id
    # in your application's database is recommended. The table also
    # includes fields for external IDs such that you can persist
    # your ID for an account in your Osso instance.
    class EnterpriseAccount < ActiveRecord::Base
      belongs_to :oauth_client
      has_many :users
      has_many :identity_providers

      def single_provider?
        identity_providers.one?
      end

      def provider
        return nil unless single_provider?

        identity_providers.first
      end

      alias identity_provider provider
    end
  end
end
