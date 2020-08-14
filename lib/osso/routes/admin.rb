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
      get '' do
        admin_protected!

        erb :admin
      end

      get '/enterprise' do
        admin_protected!

        erb :admin
      end

      get '/enterprise/:domain' do
        enterprise_protected!(params[:domain])

        erb :admin
      end

      get '/config' do
        admin_protected!

        erb :admin
      end

      get '/config/:id' do
        admin_protected!

        erb :admin
      end
    end
  end
end
