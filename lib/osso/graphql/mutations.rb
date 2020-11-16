# frozen_string_literal: true

module Osso
  module Mutations
  end
end

require_relative 'mutations/base_mutation'
require_relative 'mutations/configure_identity_provider'
require_relative 'mutations/create_identity_provider'
require_relative 'mutations/create_enterprise_account'
require_relative 'mutations/create_oauth_client'
require_relative 'mutations/delete_enterprise_account'
require_relative 'mutations/delete_identity_provider'
require_relative 'mutations/delete_oauth_client'
require_relative 'mutations/invite_admin_user'
require_relative 'mutations/regenerate_oauth_credentials'
require_relative 'mutations/set_redirect_uris'
require_relative 'mutations/update_app_config'
