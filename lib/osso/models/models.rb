# frozen_string_literal: true

# -*- SkipSchemaAnnotations

require 'sinatra/activerecord'

module Osso
  module Models
  end
end

require_relative 'access_token'
require_relative 'account'
require_relative 'app_config'
require_relative 'authorization_code'
require_relative 'enterprise_account'
require_relative 'oauth_client'
require_relative 'redirect_uri'
require_relative 'identity_provider'
require_relative 'user'
