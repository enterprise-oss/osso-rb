# frozen_string_literal: true

module Osso
  module GraphQL
    module Mutations
      class InviteAdminUser < BaseMutation
        null false

        argument :email, String, required: true
        argument :oauth_client_id, ID, required: false
        argument :role, String, required: true

        field :admin_user, Types::AdminUser, null: true
        field :errors, [String], null: false

        def resolve(email:, role:, oauth_client_id: nil)
          admin_user = Osso::Models::Account.new(
            email: email,
            role: role,
            oauth_client_id: oauth_client_id,
          )

          if admin_user.save
            verify_user(email)

            Osso::Analytics.capture(email: context[:email], event: self.class.name.demodulize, properties: {
              invited_email: email,
              invited_role: role,
              invited_oauth_client_id: oauth_client_id,
            })

            return response_data(admin_user: admin_user)
          end

          response_error(admin_user.errors)
        end

        def ready?(*)
          admin_ready?
        end

        def verify_user(email)
          context[:rodauth].account_from_login(email)
          context[:rodauth].setup_account_verification
        end
      end
    end
  end
end
