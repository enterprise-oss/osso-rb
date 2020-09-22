# frozen_string_literal: true

module Osso
  module Helpers
    module Auth
      END_USER_SCOPE = 'end-user'
      INTERNAL_SCOPE = 'internal'
      ADMIN_SCOPE    = 'admin'

      attr_accessor :current_user

      def token_protected!
        decode(token)
      rescue JWT::DecodeError
        halt 401
      end

      def enterprise_protected!(domain = nil)
        return if admin_authorized?
        return if internal_authorized?
        return if enterprise_authorized?(domain)

        halt 401 if request.post?

        redirect ENV['JWT_URL']
      end

      def internal_protected!
        return if admin_authorized?
        return if internal_authorized?

        redirect ENV['JWT_URL']
      end

      def admin_protected!
        return true if admin_authorized?

        redirect ENV['JWT_URL']
      end

      private

      def enterprise_authorized?(domain)
        decode(token)

        @current_user[:scope] == END_USER_SCOPE &&
          @current_user[:email].split('@')[1] == domain
      rescue JWT::DecodeError
        false
      end

      def internal_authorized?
        decode(token)

        @current_user[:scope] == INTERNAL_SCOPE
      rescue JWT::DecodeError
        false
      end

      def admin_authorized?
        decode(token)

        @current_user[:scope] == ADMIN_SCOPE
      rescue JWT::DecodeError
        false
      end

      def token
        request.env['HTTP_AUTHORIZATION'] || session['admin_token'] || request['admin_token']
      end

      def chomp_token
        return unless request['admin_token'].present?

        session['admin_token'] = request['admin_token']

        return if request.post?

        redirect request.path
      end

      def decode(token)
        payload, _args = JWT.decode(
          token,
          ENV['JWT_HMAC_SECRET'],
          true,
          { algorithm: 'HS256' },
        )

        @current_user = payload.symbolize_keys
      end
    end
  end
end
