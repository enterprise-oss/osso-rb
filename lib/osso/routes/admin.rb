# frozen_string_literal: true

require 'jwt'

module Osso
  class Admin < Sinatra::Base
    include AppConfig
    helpers Helpers::Auth

    before do
      chomp_token
    end

    get '/' do
      admin_protected!

      erb :'public/index'
    end

    get '/enterprise' do
      admin_protected!

      erb :admin
    end

    get '/enterprise/:domain' do
      enterprise_protected!(params[:domain])

      @enterprise = Models::EnterpriseAccount.where(
        domain: params[:domain],
      ).first_or_create

      erb :admin
    end

    get '/config' do
      admin_protected!

      erb :admin
    end
  end
end
