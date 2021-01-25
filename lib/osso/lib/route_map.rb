# frozen_string_literal: true

require 'rack/protection'

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
