# frozen_string_literal: true

module Osso
  module Error
    class OAuthError < StandardError; end

    class NoAccountForOAuthClientError < OAuthError
      def message
        'No customer account exists for the requested domain and OAuth client pair.' \
          "Review our OAuth documentation, and check you're using the correct OAuth client identifier"
      end
    end

    class InvalidOAuthClientIdentifier < MissingSamlAttributeError
      def message
        'No OAuth client exists for the requested OAuth client identifier.' \
          "Review our OAuth documentation, and check you're using the correct OAuth client identifier"
      end
    end

    class InvalidRedirectUri < MissingSamlAttributeError
      def message
        'Invalid Redirect URI for the requested OAuth client identifier.' \
          "Review our OAuth documentation, check you're using the correct OAuth client identifier " \
          'and confirm your Redirect URI allow list.'
      end
    end
  end
end
