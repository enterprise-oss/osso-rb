# frozen_string_literal: true

# This Rakefile is used in gem development in order
# to tell ActiveRecord where to find the database
# schema and migrations

require 'bundler/gem_tasks'
require 'sinatra/activerecord/rake'
require './lib/osso'

ActiveRecord::Migrator.migrations_paths = ['./lib/osso/db/migrate']
Dir.glob('lib/tasks/*.rake').each { |r| load r }

task default: :spec
