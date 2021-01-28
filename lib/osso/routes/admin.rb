# frozen_string_literal: true

require 'roda'
require 'sequel/core'

DEFAULT_VIEWS_DIR = File.join(File.expand_path(Bundler.root), 'views/rodauth')

module Osso
  class Admin < Roda
    DB = Sequel.postgres(extensions: :activerecord_connection)
    use Rack::Session::Cookie, secret: ENV.fetch('SESSION_SECRET')

    plugin :json
    plugin :json_parser
    plugin :middleware
    plugin :render, engine: 'erb', views: ENV['RODAUTH_VIEWS'] || DEFAULT_VIEWS_DIR
    plugin :route_csrf

    plugin :rodauth do
      enable :login, :verify_account, :jwt

      base_uri = URI.parse(ENV.fetch('BASE_URL'))
      base_url base_uri
      domain base_uri.host

      jwt_secret ENV.fetch('SESSION_SECRET')
      only_json? false

      email_from { "Osso <no-reply@#{domain}>" }
      verify_account_set_password? true
      use_database_authentication_functions? false

      after_login do
        Osso::Analytics.identify(email: account[:email], properties: account)
      end

      verify_account_view do
        render :admin
      end

      login_view do
        render :admin
      end

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
        Osso::Models::Account.find(
          rodauth.
          session.
          to_hash.
          stringify_keys['account_id'],
        ).context.
          merge({ rodauth: rodauth })
      end

      r.on 'admin' do
        erb :admin, layout: false
      end

      r.post 'idp' do
        onboarded = Osso::Models::IdentityProvider.
          not_pending.
          where(domain: r.params['domain']).
          exists?

        { onboarded: onboarded }.to_json
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
