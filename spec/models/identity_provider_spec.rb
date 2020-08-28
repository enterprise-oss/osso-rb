# frozen_string_literal: true

require 'spec_helper'

describe Osso::Models::IdentityProvider do
  subject { create(:okta_identity_provider) }

  describe '#assertion_consumer_service_url' do
    it 'returns the expected URI for BASE_URL' do
      ENV['BASE_URL'] = 'https://example.com'

      expect(subject.assertion_consumer_service_url).to eq(
        "https://example.com/auth/saml/#{subject.id}/callback",
      )
    end

    it 'returns the expected URI for HEROKU_APP_NAME' do
      ENV['HEROKU_APP_NAME'] = 'test'

      expect(subject.assertion_consumer_service_url).to eq(
        "https://test.herokuapp.com/auth/saml/#{subject.id}/callback",
      )
    end
  end

  describe '#saml_options' do
    it 'returns the required args' do
      expect(subject.saml_options).
        to match(
          domain: subject.domain,
          idp_cert: subject.sso_cert,
          idp_sso_target_url: subject.sso_url,
          issuer: subject.domain,
        )
    end
  end
end
