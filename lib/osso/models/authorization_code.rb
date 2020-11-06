# frozen_string_literal: true

module Osso
  module Models
    class AuthorizationCode < ActiveRecord::Base
      include OAuth2Token

      def access_token
        @access_token ||= expired! &&
          user.access_tokens.create(oauth_client: oauth_client)
      end

      def create_access_token(requested:)
        user.access_tokens.create(oauth_client: oauth_client)
      end
    end
  end
end

# == Schema Information
#
# Table name: authorization_codes
#
#  id              :uuid             not null, primary key
#  token           :string
#  redirect_uri    :string
#  expires_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :uuid
#  oauth_client_id :uuid
#
# Indexes
#
#  index_authorization_codes_on_oauth_client_id  (oauth_client_id)
#  index_authorization_codes_on_token            (token) UNIQUE
#  index_authorization_codes_on_user_id          (user_id)
#
