# frozen_string_literal: true

module Osso
  module Models
    class RedirectUri < ActiveRecord::Base
      belongs_to :oauth_client

      # TODO
      # before_validation :set_primary, on: :creaet, :update

      private

      def set_primary
        if primary_was.true? && primary.false?

        end
      end
    end
  end
end

# == Schema Information
#
# Table name: redirect_uris
#
#  id              :uuid             not null, primary key
#  uri             :string           not null
#  primary         :boolean          default(FALSE), not null
#  oauth_client_id :uuid
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_redirect_uris_on_oauth_client_id  (oauth_client_id)
#  index_redirect_uris_on_uri_and_primary  (uri,primary) UNIQUE
#
