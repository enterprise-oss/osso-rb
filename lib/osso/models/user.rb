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
