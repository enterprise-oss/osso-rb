# frozen_string_literal: true

require 'jwt'

module Osso
  class Admin < Sinatra::Base
    include AppConfig
    helpers Helpers::Auth
    register Sinatra::Namespace
    use Osso::Rodauth

    private

    def current_account
      Osso::Models::Account.find(env['rodauth'].session['account_id']).
        context.
        merge({ rodauth: env['rodauth'] })
    end
  end
end
