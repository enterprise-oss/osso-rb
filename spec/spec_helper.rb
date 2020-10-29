# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

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
ENV['BASE_URL'] = 'https://example.com'

require File.expand_path '../lib/osso.rb', __dir__

require File.expand_path 'support/spec_app', __dir__

module RSpecMixin
  PEM_HEADER = "-----BEGIN CERTIFICATE-----\n"
  PEM_FOOTER = "\n-----END CERTIFICATE-----"

  include Rack::Test::Methods

  def app
    SpecApp
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

  def spec_views
    "#{File.dirname(__FILE__)}/support/views"
  end

  def valid_x509_pem
    raw = File.read("#{File.dirname(__FILE__)}/support/fixtures/test.pem")
    OpenSSL::X509::Certificate.new(raw).to_pem
  end

  def raw_x509_string
    raw = valid_x509_pem.match(/#{PEM_HEADER}(?<cert>.*)#{PEM_FOOTER}/m)
    raw[:cert]
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
