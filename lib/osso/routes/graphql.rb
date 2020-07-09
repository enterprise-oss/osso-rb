# frozen_string_literal: true

module Osso
  class Admin < Sinatra::Base
    include AppConfig
    helpers Helpers::Auth

    post '/graphql' do
      enterprise_protected!

      result = OssoSchema.execute(
        params[:query],
        variables: params[:variables],
        context: { scope: current_scope },
      )

      json result
    end
  end
end
