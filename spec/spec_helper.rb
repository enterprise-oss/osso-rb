# frozen_string_literal: true

require 'database_cleaner/active_record'
require 'factory_bot'
require 'faker'
require 'omniauth'
require 'pry'
require 'rack/test'
require 'rspec'
require 'webmock/rspec'

ENV['RACK_ENV'] = 'test'
ENV['SESSION_SECRET'] = 'supersecret'

require File.expand_path '../lib/osso.rb', __dir__

module RSpecMixin
  include Rack::Test::Methods

  def app
    Rack::URLMap.new(
      '/admin' => Osso::Admin,
      '/auth' => Osso::Auth,
      '/oauth' => Osso::Oauth,
    )
  end

  def mock_saml_omniauth(email: 'user@enterprise.com', id: SecureRandom.uuid)
    OmniAuth.config.add_mock(:saml,
      extra: {
        response_object: {
          attributes: {
            'id': id,
            'email': email,
          },
        },
      })
  end

  def last_json_response
    JSON.parse(last_response.body, symbolize_names: true)
  end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    ActiveRecord::Base.establish_connection
    FactoryBot.find_definitions
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  OmniAuth.config.test_mode = true
  OmniAuth.config.logger = Logger.new('/dev/null')
  WebMock.disable_net_connect!(allow_localhost: true)
end
