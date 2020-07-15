# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class BaseMutation < ::GraphQL::Schema::RelayClassicMutation
        object_class Types::BaseObject
        # field_class Types::BaseField
        input_object_class Types::BaseInputObject

        def response_data(data)
          data.merge(errors: [])
        end

        def response_error(error)
          error.merge(data: nil)
        end
      end
    end
  end
end
