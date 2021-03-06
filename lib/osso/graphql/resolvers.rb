# frozen_string_literal: true

module Osso
  module GraphQL
    module Resolvers
    end
  end
end

require_relative 'resolvers/base_resolver'
require_relative 'resolvers/enterprise_account'
require_relative 'resolvers/enterprise_accounts'
require_relative 'resolvers/oauth_clients'
