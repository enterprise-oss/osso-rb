# frozen_string_literal: true

module Osso
  module Helpers
    module Auth
      attr_accessor :current_scope
      
      def enterprise_protected!(domain = nil)
        return if admin_authorized?
        return if enterprise_authorized?(domain)

        redirect ENV['JWT_URL']
      end

      def enterprise_authorized?(domain)
        payload, _args = JWT.decode(
          token,
          ENV['JWT_HMAC_SECRET'],
          true,
          { algorithm: 'HS256' },
        )

        @current_scope = payload['scope']

        true
      rescue JWT::DecodeError
        false
      end

      def admin_protected!
        return if admin_authorized?

        redirect ENV['JWT_URL']
      end

      def admin_authorized?
        payload, _args = JWT.decode(
          token,
          ENV['JWT_HMAC_SECRET'],
          true,
          { algorithm: 'HS256' },
        )

        if payload['scope'] == 'admin'
          @current_scope = :admin
          return true
        end

        false
      rescue JWT::DecodeError
        false
      end

      def token
        request.env['admin_token'] || session['admin_token'] || request['admin_token']
      end

      def chomp_token
        return unless request['admin_token'].present?

        session['admin_token'] = request['admin_token']

        return if request.post?

        redirect request.path
      end
    end
  end
end