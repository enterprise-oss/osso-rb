# frozen_string_literal: true

require 'spec_helper'

describe Osso::GraphQL::Schema do
  describe 'CreateIdentityProvider' do
    let(:identity_provider) { create(:identity_provider) }
    let(:mutation) do
      <<~GRAPHQL
         mutation ConfigureIdentityProvider($input: ConfigureIdentityProviderInput!) {
          configureIdentityProvider(input: $input) {
            identityProvider {
              id
              domain
              configured
              enterpriseAccountId
              service
              acsUrl
              ssoCert
              ssoUrl
            }
          }
        }
      GRAPHQL
    end

    subject do
      described_class.execute(
        mutation,
        variables: variables,
        context: { scope: current_scope },
      )
    end

    describe 'for an admin user' do
      let(:current_scope) { :admin }
      describe 'without a service' do
        let(:variables) do
          {
            input: {
              id: identity_provider.id,
              service: 'OKTA',
              ssoUrl: 'https://example.com',
              ssoCert: 'BEGIN_CERTIFICATE',
            },
          }
        end

        it 'configures an identity provider' do
          expect(subject.dig('data', 'configureIdentityProvider', 'identityProvider', 'configured')).
            to be true
        end
      end

      xdescribe 'with a service' do
        let(:variables) { { input: { enterpriseAccountId: enterprise_account.id, service: 'OKTA' } } }

        it 'creates an identity provider for given service ' do
          expect { subject }.to change { enterprise_account.identity_providers.count }.by(1)
          expect(subject.dig('data', 'createIdentityProvider', 'identityProvider', 'service')).
            to eq('OKTA')
        end
      end
    end

    xdescribe 'for an email scoped user' do
      let(:domain) { Faker::Internet.domain_name }
      let(:current_scope) { domain }
      let(:enterprise_account) { create(:enterprise_account, domain: domain) }

      describe 'without a service' do
        let(:variables) { { input: { enterpriseAccountId: enterprise_account.id } } }

        it 'creates an identity provider' do
          expect { subject }.to change { enterprise_account.identity_providers.count }.by(1)
          expect(subject.dig('data', 'createIdentityProvider', 'identityProvider', 'domain')).
            to eq(domain)
        end
      end

      describe 'with a service' do
        let(:variables) { { input: { enterpriseAccountId: enterprise_account.id, service: 'OKTA' } } }

        it 'creates an identity provider for given service ' do
          expect { subject }.to change { enterprise_account.identity_providers.count }.by(1)
          expect(subject.dig('data', 'createIdentityProvider', 'identityProvider', 'service')).
            to eq('OKTA')
        end
      end
    end
  end
end
