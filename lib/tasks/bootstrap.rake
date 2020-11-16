# frozen_string_literal: true

require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require 'osso'

namespace :osso do
  desc 'Bootstrap Osso data for a deployment'
  task :bootstrap do
    %w[Production Staging Development].each do |environment|
      Osso::Models::OauthClient.create!(
        name: environment,
      ) unless Osso::Models::OauthClient.find_by_name(environment)
    end

    Osso::Models::AppConfig.create

    admin_email = ENV['ADMIN_EMAIL']

    if admin_email
      admin = Osso::Models::Account.create(
        email: admin_email,
        status_id: 1,
        role: 'admin',
      )

      rodauth = Osso::Admin.rodauth.new(Osso::Admin.new({
        request: {
          domain: URI.parse(ENV['BASE_URL']).host,
          base_url: ENV['BASE_URL'],
        }
      }))
      account = rodauth.account_from_login(admin_email)
      rodauth.setup_account_verification
    end
  end
end
