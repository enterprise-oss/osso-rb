# frozen_string_literal: true

require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require 'osso'

namespace :osso do
  desc 'Bootstrap Osso data for a deployment'
  task :bootstrap do
    %w[Production Staging Development].each do |environement|
      Osso::Models::OauthClient.create!(
        name: environement,
      )
    end

    Osso::Models::AppConfig.create!
  end
end
