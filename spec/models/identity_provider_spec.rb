# frozen_string_literal: true

require 'spec_helper'

describe Osso::Models::IdentityProvider do
  subject { create(:okta_identity_provider) }

  describe '#assertion_consumer_service_url' do
    it 'returns the expected URI for BASE_URL' do
      ENV['HEROKU_APP_NAME'] = nil
      ENV['BASE_URL'] = 'https://example.com'

      expect(subject.assertion_consumer_service_url).to eq(
        "#{ENV['BASE_URL']}/auth/saml/#{subject.id}/callback",
      )
    end

    it 'returns the expected URI for HEROKU_APP_NAME' do
      ENV['HEROKU_APP_NAME'] = 'test'

      expect(subject.assertion_consumer_service_url).to eq(
        "https://test.herokuapp.com/auth/saml/#{subject.id}/callback",
      )
    end
  end

  describe '#acs_url_validator' do
    it 'returns a regex escaped string' do
      allow(subject).to receive(:acs_url).and_return(
        'https://foo.com/auth/saml/callback'
      )

      expect(subject.acs_url_validator).to eq(
        'https://foo\\.com/auth/saml/callback'
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

  describe '#validate_sso_cert' do
    it 'rejects an invalid cert' do
      subject.update(sso_cert: 'bad-cert')

      expect(subject.errors.full_messages.first).to include('x509 Certificate is malformed')
    end

    it 'massages a cert with header and footer' do
      subject.update(sso_cert: valid_x509_pem)

      expect(subject.errors).to be_empty
      expect(subject.sso_cert).to_not include('BEGIN CERTIFICATE')
    end

    it 'accepts a cert without header and footer' do
      subject.update(sso_cert: raw_x509_string)

      expect(subject.errors).to be_empty
    end
  end
end
