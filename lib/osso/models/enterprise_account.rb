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
        identity_providers.not_pending.one?
      end

      def provider
        return nil unless single_provider?

        identity_providers.first
      end

      alias identity_provider provider
    end
  end
end

# == Schema Information
#
# Table name: enterprise_accounts
#
#  id              :uuid             not null, primary key
#  domain          :string           not null
#  external_uuid   :uuid
#  external_int_id :integer
#  external_id     :string
#  oauth_client_id :uuid
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_enterprise_accounts_on_domain           (domain) UNIQUE
#  index_enterprise_accounts_on_oauth_client_id  (oauth_client_id)
#
