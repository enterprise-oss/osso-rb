# frozen_string_literal: true

require 'posthog-ruby'

module Osso
  # Osso::Analytics provides an interface to track product analytics for any provider.
  # Osso recommends PostHog as an open source solution for your product analytics needs.
  # If you want to use another product analytics provider, you can patch the Osso::Analytics
  # class yourself in your parent application. Be sure to implement the public
  # .identify and .capture class methods with the required method signatures and require
  # your class after requiring Osso.
  class Analytics
    class << self
      def identify(email:, properties: {})
        return unless configured?

        client.identify({
                          distinct_id: email,
                          properties: properties.merge(instance_properties),
                        })
      end

      def capture(email:, event:, properties: {})
        return unless configured?

        client.capture(
          distinct_id: email,
          event: event,
          properties: properties.merge(instance_properties),
        )
      end

      private

      def configured?
        ENV['POSTHOG_API_KEY'].present?
      end

      def client
        @client ||= PostHog::Client.new({
                                          api_key: ENV['POSTHOG_API_KEY'],
                                          api_host: ENV['POSTHOG_HOST'],
                                          on_error: proc { |_status, msg| print msg },
                                        })
      end

      def instance_properties
        {
          instance_url: ENV['BASE_URL'],
          osso_plan: ENV['OSSO_PLAN'],
        }
      end
    end
  end
end
