# frozen_string_literal: true

require 'spec_helper'

describe Osso::Auth do
  describe 'get /auth/saml/:uuid' do
    describe 'for an Okta SAML provider' do
      let(:enterprise) { create(:enterprise_with_okta) }
      let(:okta_provider) { enterprise.identity_providers.first }
      it 'uses omniauth saml' do
        get("/auth/saml/#{okta_provider.id}")

        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.url).to match("auth/saml/#{okta_provider.id}")
      end
    end

    describe 'for an Azure SAML provider' do
      let(:enterprise) { create(:enterprise_with_okta) }
      let(:azure_provider) { enterprise.identity_providers.first }
      it 'uses omniauth saml' do
        get("/auth/saml/#{azure_provider.id}")

        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.url).to match("auth/saml/#{azure_provider.id}")
      end
    end
  end
  describe 'post /auth/saml/:uuid/callback' do
    describe 'for an Okta SAML provider' do
      let(:enterprise) { create(:enterprise_with_okta) }
      let(:okta_provider) { enterprise.identity_providers.first }

      describe "on the user's first authentication" do
        it 'creates a user' do
          mock_saml_omniauth

          expect do
            post(
              "/auth/saml/#{okta_provider.id}/callback",
              nil,
              {
                'omniauth.auth' => OmniAuth.config.mock_auth[:saml],
                'identity_provider' => okta_provider,
              },
            )
          end.to change { Osso::Models::User.count }.by(1)
        end

        it 'creates an authorization_code' do
          mock_saml_omniauth

          expect do
            post(
              "/auth/saml/#{okta_provider.id}/callback",
              nil,
              {
                'omniauth.auth' => OmniAuth.config.mock_auth[:saml],
                'identity_provider' => okta_provider,
              },
            )
          end.to change { Osso::Models::AuthorizationCode.count }.by(1)
        end

        describe 'for an IDP initiated login' do
          it 'redirects with a default state' do
            mock_saml_omniauth

            post(
              "/auth/saml/#{okta_provider.id}/callback",
              nil,
              {
                'omniauth.auth' => OmniAuth.config.mock_auth[:saml],
                'identity_provider' => okta_provider,
              },
            )
            expect(last_response).to be_redirect
            follow_redirect!
            expect(last_request.url).to match(/.*state=IDP_INITIATED$/)
          end
        end
      end

      describe 'on subsequent authentications' do
        let!(:enterprise) { create(:enterprise_with_okta) }
        let!(:okta_provider) { enterprise.identity_providers.first }
        let(:user) { create(:user, identity_provider_id: okta_provider.id) }

        before do
          mock_saml_omniauth(email: user.email, id: user.idp_id)
        end

        it 'creates a user' do
          expect do
            post(
              "/auth/saml/#{okta_provider.id}/callback",
              nil,
              {
                'omniauth.auth' => OmniAuth.config.mock_auth[:saml],
                'identity_provider' => okta_provider,
              },
            )
          end.to_not(change { Osso::Models::User.count })
        end
      end
    end

    describe 'for an (Azure) ADFS SAML provider' do
      let(:enterprise) { create(:enterprise_with_azure) }
      let(:azure_provider) { enterprise.provider }

      describe "on the user's first authentication" do
        it 'creates a user' do
          mock_saml_omniauth

          expect do
            post(
              "/auth/saml/#{azure_provider.id}/callback",
              nil,
              {
                'omniauth.auth' => OmniAuth.config.mock_auth[:saml],
                'identity_provider' => azure_provider,
              },
            )
          end.to change { Osso::Models::User.count }.by(1)
        end
      end

      describe 'on subsequent authentications' do
        let!(:enterprise) { create(:enterprise_with_azure) }
        let!(:azure_provider) { enterprise.provider }
        let(:user) { create(:user, identity_provider_id: azure_provider.id) }

        before do
          mock_saml_omniauth(email: user.email, id: user.idp_id)
        end

        it 'creates a user' do
          expect do
            post(
              "/auth/saml/#{azure_provider.id}/callback",
              nil,
              {
                'omniauth.auth' => OmniAuth.config.mock_auth[:saml],
                'identity_provider' => azure_provider,
              },
            )
          end.to_not(change { Osso::Models::User.count })
        end
      end
    end
  end
end
