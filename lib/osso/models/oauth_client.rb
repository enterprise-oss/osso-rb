# frozen_string_literal: true

require 'securerandom'
module Osso
  module Models
    class OauthClient < ActiveRecord::Base
      has_many :access_tokens
      has_many :enterprise_accounts
      has_many :refresh_tokens
      has_many :identity_providers
      has_many :redirect_uris

      before_validation :generate_secrets, on: :create
      validates :name, :secret, presence: true
      validates :identifier, presence: true, uniqueness: true

      def primary_redirect_uri
        redirect_uris.find(&:primary)
      end

      def redirect_uri_values
        redirect_uris.map(&:uri)
      end

      def generate_secrets
        self.identifier ||= SecureRandom.hex(16)
        self.secret ||= SecureRandom.hex(32)
      end
    end
  end
end

# == Schema Information
#
# Table name: oauth_clients
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  secret     :string           not null
#  identifier :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_oauth_clients_on_identifier  (identifier) UNIQUE
#
