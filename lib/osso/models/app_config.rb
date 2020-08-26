# frozen_string_literal: true

module Osso
  module Models
    class AppConfig < ::ActiveRecord::Base
      validate :limit_to_one, on: :create

      def self.find
        first
      end

      private

      def limit_to_one
        return if Osso::Models::AppConfig.count.zero?

        errors[:base] << 'AppConfig already exists'
      end
    end
  end
end

# == Schema Information
#
# Table name: app_configs
#
#  id            :uuid             not null, primary key
#  contact_email :string
#  logo_url      :string
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
