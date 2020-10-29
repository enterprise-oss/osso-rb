# frozen_string_literal: true

module Osso
  module Models
    class Account < ::ActiveRecord::Base
      enum status_id: { 1 => :Unverified, 2 => :Verified, 3 => :Closed }

      def context
        {
          email: email,
          id: id,
          scope: scope,
        }
      end
    end
  end
end
