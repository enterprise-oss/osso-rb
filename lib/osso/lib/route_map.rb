# frozen_string_literal: true

module Osso
  module RouteMap
    def self.included(klass)
      klass.class_eval do
        use Osso::Admin
        use Osso::Auth
        use Osso::Oauth
      end
    end
  end
end
