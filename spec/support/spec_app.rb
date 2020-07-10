# frozen_string_literal: true

class SpecApp < Sinatra::Base
  include Osso::RouteMap

  get '/health' do
    'ok'
  end
end
