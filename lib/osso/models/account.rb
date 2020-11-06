# frozen_string_literal: true

module Osso
  module Models
    class Account < ::ActiveRecord::Base
      enum status_id: { 1 => :Unverified, 2 => :Verified, 3 => :Closed }

      def context
        {
          email: email,
          id: id,
          scope: role,
          oauth_client_id: oauth_client_id,
        }
      end
    end
  end
end

# == Schema Information
#
# Table name: accounts
#
#  id              :uuid             not null, primary key
#  email           :citext           not null
#  status_id       :integer          default(NULL), not null
#  role            :string           default("admin"), not null
#  oauth_client_id :string
#
# Indexes
#
#  index_accounts_on_email            (email) UNIQUE WHERE (status_id = ANY (ARRAY[1, 2]))
#  index_accounts_on_oauth_client_id  (oauth_client_id)
#
