# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength

module Osso
  module RouteMap
    def self.included(klass)
      klass.class_eval do
        use Osso::Admin
        use Osso::Auth
        use Osso::Oauth

        post '/graphql' do
          enterprise_protected!

          result = Osso::GraphQL::Schema.execute(
            params[:query],
            variables: params[:variables],
            context: { scope: current_scope },
          )

          json result
        end
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
