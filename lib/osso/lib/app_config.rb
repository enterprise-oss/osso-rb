# frozen_string_literal: true

require 'rack/contrib'

module Osso
  module AppConfig
    def self.included(klass)
      klass.class_eval do
        use Rack::JSONBodyParser
        use Rack::Session::Cookie, secret: ENV['SESSION_SECRET']

        error ActiveRecord::RecordNotFound do
          status 404
        end

        set :root, Dir.pwd
      end
    end
  end
end
