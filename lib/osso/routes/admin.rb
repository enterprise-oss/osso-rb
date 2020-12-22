# frozen_string_literal: true

require 'roda'
require 'sequel/core'

DEFAULT_VIEWS_DIR = File.join(File.expand_path(Bundler.root), 'views/rodauth')

module Osso
  class Admin < Roda
    DB = Sequel.postgres(extensions: :activerecord_connection)
    use Rack::Session::Cookie, secret: ENV.fetch('SESSION_SECRET')

    plugin :middleware
    plugin :render, engine: 'erb', views: ENV['RODAUTH_VIEWS'] || DEFAULT_VIEWS_DIR
    plugin :route_csrf

    plugin :rodauth do
      enable :login, :verify_account
      base_uri = URI.parse(ENV.fetch('BASE_URL'))
      base_url base_uri
      domain base_uri.host

      email_from { "Osso <no-reply@#{domain}>" }
      verify_account_set_password? true
      already_logged_in { redirect login_redirect }
      use_database_authentication_functions? false


      verify_account_email_subject do
        DB[:accounts].one? ? 'Your Osso instance is ready' : 'You\'ve been invited to start using Osso'
      end

      verify_account_email_body do
        DB[:accounts].one? ? render('verify-first-account-email') : render('verify-account-email')
      end

      before_create_account_route do
        request.halt unless DB[:accounts].empty?
      end
    end

    alias erb render

    route do |r|
      r.rodauth

      def current_account
        Osso::Models::Account.find(rodauth.session['account_id']).
          context.
          merge({ rodauth: rodauth })
      end

      r.on 'admin' do
        rodauth.require_authentication
        erb :admin, layout: false
      end

      r.post 'graphql' do
        rodauth.require_authentication

        result = Osso::GraphQL::Schema.execute(
          r.params['query'],
          variables: r.params['variables'],
          context: current_account,
        )

        result.to_json
      end

      env['rodauth'] = rodauth
    end
  end
end
