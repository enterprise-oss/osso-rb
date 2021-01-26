# frozen_string_literal: true

require 'spec_helper'

describe Osso::Oauth do
  before do
    described_class.set(:views, spec_views)
  end

  let(:client) { create(:oauth_client) }

  describe 'get /oauth/authorize' do
    describe 'with a valid client ID and redirect URI' do
      describe 'for a domain that does not belong to an enterprise' do
        it 'renders an error page' do
          create(:enterprise_with_okta, domain: 'foo.com')

          get(
            '/oauth/authorize',
            domain: 'bar.org',
            client_id: client.identifier,
            response_type: 'code',
            redirect_uri: client.redirect_uri_values.sample,
          )

          expect(last_response.status).to eq(200)
        end
      end

      describe 'for a request without email or domain' do
        it 'renders the hosted login page' do
          get(
            '/oauth/authorize',
            client_id: client.identifier,
            response_type: 'code',
            redirect_uri: client.redirect_uri_values.sample,
          )

          expect(last_response).to be_ok
          expect(last_response.body).to eq('HOSTED LOGIN')
        end
      end

      describe 'for an enterprise domain with one SAML provider' do
        it 'renders the saml login form' do
          enterprise = create(:enterprise_with_okta, oauth_client: client)

          get(
            '/oauth/authorize',
            domain: enterprise.domain,
            client_id: client.identifier,
            response_type: 'code',
            redirect_uri: client.redirect_uri_values.sample,
          )

          provider_id = enterprise.identity_providers.first.id

          expect(last_response.body).to match(provider_id)
        end
      end

      describe 'for an enterprise domain with multiple SAML providers' do
        it 'renders the multiple providers screen' do
          enterprise = create(:enterprise_with_multiple_providers, oauth_client: client)

          get(
            '/oauth/authorize',
            domain: enterprise.domain,
            client_id: client.identifier,
            response_type: 'code',
            redirect_uri: client.redirect_uri_values.sample,
          )

          expect(last_response).to be_ok
          expect(last_response.body).to eq('MULITPLE PROVIDERS')
        end
      end

      describe "for an existing user's email address" do
        it 'renders the saml login form' do
          enterprise = create(:enterprise_with_okta, oauth_client: client)
          provider_id = enterprise.identity_providers.first.id
          user = create(:user, email: "user@#{enterprise.domain}", identity_provider_id: provider_id)

          get(
            '/oauth/authorize',
            email: user.email,
            client_id: client.identifier,
            response_type: 'code',
            redirect_uri: client.redirect_uri_values.sample,
          )

          expect(last_response.body).to match(provider_id)
        end
      end

      describe "for a new user's email address belonging to an enterprise with one SAML provider" do
        it 'renders the saml login form' do
          enterprise = create(:enterprise_with_okta, oauth_client: client)

          get(
            '/oauth/authorize',
            email: "user@#{enterprise.domain}",
            client_id: client.identifier,
            response_type: 'code',
            redirect_uri: client.redirect_uri_values.sample,
          )

          provider_id = enterprise.identity_providers.first.id

          expect(last_response.body).to match(provider_id)
        end
      end

      describe "for a new user's email address belonging to an enterprise with multiple SAML providers" do
        it 'renders the multiple providers screen' do
          enterprise = create(:enterprise_with_multiple_providers, oauth_client: client)

          get(
            '/oauth/authorize',
            email: "user@#{enterprise.domain}",
            client_id: client.identifier,
            response_type: 'code',
            redirect_uri: client.redirect_uri_values.sample,
          )

          expect(last_response).to be_ok
          expect(last_response.body).to eq('MULITPLE PROVIDERS')
        end
      end
    end
  end

  describe 'post /oauth/token' do
    describe 'with a valid unexpired code, client secret, client ID and redirect URI' do
      it 'returns an access token' do
        user = create(:user)
        code = user.authorization_codes.valid.first

        post(
          '/oauth/token',
          client_id: client.identifier,
          client_secret: client.secret,
          grant_type: 'authorization_code',
          redirect_uri: code.redirect_uri,
          code: code.token,
        )

        expect(last_response.status).to eq(200)
        expect(last_json_response.to_h).to match(
          access_token: a_string_matching(/\w{64}/),
          expires_in: an_instance_of(Integer),
          token_type: 'bearer',
        )
      end
    end
  end

  describe 'get /oauth/me' do
    describe 'with a valid unexpired access token in params' do
      it 'returns the user' do
        user = create(:user)
        code = user.authorization_codes.valid.first

        get(
          '/oauth/me',
          access_token: code.access_token.to_bearer_token,
        )

        expect(last_response.status).to eq(200)
        expect(last_json_response).to eq(
          email: user.email,
          id: user.id,
          idp: 'Okta',
          requested: code.requested.symbolize_keys,
        )
      end
    end

    describe 'with a valid unexpired access token in headers' do
      it 'returns the user' do
        user = create(:user)
        code = user.authorization_codes.valid.first

        get(
          '/oauth/me',
          nil,
          {
            'HTTP_AUTHORIZATION' => "Bearer: #{code.access_token.to_bearer_token}",
          },
        )

        expect(last_response.status).to eq(200)
        expect(last_json_response).to eq(
          email: user.email,
          id: user.id,
          idp: 'Okta',
          requested: code.requested.symbolize_keys,
        )
      end
    end

    describe 'with an expired access token' do
      it 'returns 404' do
        code = create(:authorization_code)
        code.access_token.expired!

        get(
          '/oauth/me',
          access_token: code.access_token.to_bearer_token,
        )

        expect(last_response.status).to eq(404)
      end
    end

    describe 'with an invalid access token' do
      it 'returns 404' do
        get(
          '/oauth/me',
          access_token: SecureRandom.hex(32),
        )

        expect(last_response.status).to eq(404)
      end
    end
  end
end
