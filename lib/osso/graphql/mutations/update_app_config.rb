# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class UpdateAppConfig < BaseMutation
        null false

        argument :name, String, required: false
        argument :logo_url, String, required: false
        argument :contact_email, String, required: false

        field :app_config, Types::AppConfig, null: true
        field :errors, [String], null: false

        def resolve(**args)
          app_config = Osso::Models::AppConfig.find
          return response_data(app_config: app_config) if app_config.update(**args)

          response_error(errors: e)
        end

        def ready?(*)
          admin_ready?
        end
      end
    end
  end
end
