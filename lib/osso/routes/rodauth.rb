# frozen_string_literal: true

require 'roda'
require 'sequel/core'

module Osso
  class Rodauth < Roda
    DB = Sequel.postgres(extensions: :activerecord_connection)
    use Rack::Session::Cookie, secret: ENV['SESSION_SECRET']

    plugin :middleware

    plugin :render, engine: 'erb', views: File.join(File.expand_path(Bundler.root), 'views/rodauth'), cache: nil
    plugin :render, engine: 'erb', views: 'lib/osso/views' if ENV['RACK_ENV'] == 'test'
    plugin :route_csrf

    plugin :rodauth do
      enable :login, :verify_account
      verify_account_set_password? true
      already_logged_in { redirect login_redirect }

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

      r.post '/graphql' do
        rodauth.require_authentication

        result = Osso::GraphQL::Schema.execute(
          params[:query],
          variables: params[:variables],
          context: current_account,
        )

        json result
      end

      env['rodauth'] = rodauth
    end
  end
end