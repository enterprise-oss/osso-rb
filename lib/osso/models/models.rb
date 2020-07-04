# frozen_string_literal: true

require 'sinatra/activerecord'

module Osso
  module Models
  end
end

require_relative 'access_token'
require_relative 'authorization_code'
require_relative 'enterprise_account'
require_relative 'oauth_client'
require_relative 'redirect_uri'
require_relative 'saml_provider'
require_relative 'user'
