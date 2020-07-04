# frozen_string_literal: true

load 'active_record/railties/databases.rake'
require "sinatra/activerecord/rake/activerecord_#{ActiveRecord::VERSION::MAJOR}"
