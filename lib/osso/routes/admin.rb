# frozen_string_literal: true

require 'jwt'

module Osso
  class Admin < Sinatra::Base
    include AppConfig
    helpers Helpers::Auth
    register Sinatra::Namespace

    before do
      chomp_token
    end

    namespace '/admin' do
      get '/login' do
        token_protected!

        erb :admin, layout: false
      end

      get '' do
        internal_protected!

        erb :admin, layout: false
      end

      get '/enterprise' do
        token_protected!

        erb :admin, layout: false
      end

      get '/enterprise/:domain' do
        enterprise_protected!(params[:domain])

        erb :admin, layout: false
      end

      get '/config' do
        admin_protected!

        erb :admin, layout: false
      end

      get '/config/:id' do
        admin_protected!

        erb :admin, layout: false
      end
    end
  end
end
