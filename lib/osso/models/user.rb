# frozen_string_literal: true

module Osso
  module Models
    class User < ActiveRecord::Base
      belongs_to :enterprise_account
      belongs_to :identity_provider
      has_many :authorization_codes, dependent: :delete_all
      has_many :access_tokens, dependent: :delete_all

      def oauth_client
        identity_provider.oauth_client
      end

      def as_json(*)
        {
          email: email,
          id: id,
          idp: identity_provider.name,
        }
      end
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                    :uuid             not null, primary key
#  email                 :string           not null
#  idp_id                :string           not null
#  identity_provider_id  :uuid
#  enterprise_account_id :uuid
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_users_on_email_and_idp_id       (email,idp_id) UNIQUE
#  index_users_on_enterprise_account_id  (enterprise_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (identity_provider_id => identity_providers.id)
#
