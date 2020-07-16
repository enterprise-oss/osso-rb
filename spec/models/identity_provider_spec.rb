# frozen_string_literal: true

require 'spec_helper'

describe Osso::Models::IdentityProvider do
  subject { create(:okta_identity_provider) }

  describe '#assertion_consumer_service_url' do
    it 'returns the expected URI' do
      ENV['BASE_URL'] = 'https://example.com'

      expect(subject.assertion_consumer_service_url).to eq(
        "https://example.com/auth/saml/#{subject.id}/callback",
      )
    end
  end
end
