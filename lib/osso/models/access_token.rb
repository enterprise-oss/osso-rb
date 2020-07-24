# frozen_string_literal: true

module Osso
  module Models
    class AccessToken < ::ActiveRecord::Base
      include OAuth2Token
      self.default_lifetime = 10.minutes
      belongs_to :refresh_token

      def to_bearer_token
        Rack::OAuth2::AccessToken::Bearer.new(
          access_token: token,
          expires_in: expires_in,
        )
      end

      private

      def setup
        super
        return unless refresh_token

        self.user = refresh_token.user
        self.client = refresh_token.client
        self.expires_at = [expires_at, refresh_token.expires_at].min
      end
    end
  end
end

# == Schema Information
#
# Table name: access_tokens
#
#  id              :uuid             not null, primary key
#  token           :string
#  expires_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :uuid
#  oauth_client_id :uuid
#
# Indexes
#
#  index_access_tokens_on_oauth_client_id  (oauth_client_id)
#  index_access_tokens_on_user_id          (user_id)
#
