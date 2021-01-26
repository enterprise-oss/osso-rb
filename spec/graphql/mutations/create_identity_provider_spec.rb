# frozen_string_literal: true

require 'spec_helper'

describe Osso::GraphQL::Schema do
  describe 'CreateIdentityProvider' do
    let(:enterprise_account) { create(:enterprise_account) }
    let(:oauth_client) { create(:oauth_client) }
    let(:mutation) do
      <<~GRAPHQL
         mutation CreateIdentityProvider($input: CreateIdentityProviderInput!) {
          createIdentityProvider(input: $input) {
            identityProvider {
              id
              domain
              enterpriseAccountId
              service
              acsUrl
            }
          }
        }
      GRAPHQL
    end

    subject do
      described_class.execute(
        mutation,
        variables: variables,
        context: current_context,
      )
    end

    describe 'for an admin user' do
      let(:current_context) do
        { scope: 'admin' }
      end
      describe 'without a service' do
        let(:variables) do
          {
            input:
              {
                enterpriseAccountId: enterprise_account.id,
                oauthClientId: oauth_client.id,
              },
          }
        end

        it 'creates an identity provider' do
          expect { subject }.to change { enterprise_account.identity_providers.count }.by(1)
          expect(subject.dig('data', 'createIdentityProvider', 'identityProvider', 'domain')).
            to eq(enterprise_account.domain)
        end
      end

      describe 'with a service' do
        let(:variables) do
          {
            input:
              {
                enterpriseAccountId: enterprise_account.id,
                service: 'OKTA',
                oauthClientId: oauth_client.id,
              },
          }
        end
        it 'creates an identity provider for given service ' do
          expect { subject }.to change { enterprise_account.identity_providers.count }.by(1)
          expect(subject.dig('data', 'createIdentityProvider', 'identityProvider', 'service')).
            to eq('OKTA')
        end
      end
    end

    describe 'for an email scoped user' do
      let(:domain) { Faker::Internet.domain_name }
      let(:current_context) do
        {
          scope: 'end-user',
          email: "user@#{domain}",
        }
      end
      let(:enterprise_account) { create(:enterprise_account, domain: domain) }

      describe 'without a service' do
        let(:variables) do
          {
            input:
              {
                enterpriseAccountId: enterprise_account.id,
                oauthClientId: oauth_client.id,
              },
          }
        end

        it 'creates an identity provider' do
          expect { subject }.to change { enterprise_account.identity_providers.count }.by(1)
          expect(subject.dig('data', 'createIdentityProvider', 'identityProvider', 'domain')).
            to eq(domain)
        end
      end

      describe 'with a service' do
        let(:variables) do
          {
            input:
              {
                enterpriseAccountId: enterprise_account.id,
                oauthClientId: oauth_client.id,
                service: 'OKTA',
              },
          }
        end

        it 'creates an identity provider for given service ' do
          expect { subject }.to change { enterprise_account.identity_providers.count }.by(1)
          expect(subject.dig('data', 'createIdentityProvider', 'identityProvider', 'service')).
            to eq('OKTA')
        end
      end
    end

    describe 'for a wrong email scoped user' do
      let(:domain) { Faker::Internet.domain_name }
      let(:current_context) do
        {
          scope: 'end-user',
          email: "user@#{domain}",
        }
      end
      let(:enterprise_account) { create(:enterprise_account, domain: domain) }
      let(:target_account) { create(:enterprise_account) }

      describe 'without a service' do
        let(:variables) do
          {
            input:
              {
                enterpriseAccountId: target_account.id,
                oauthClientId: oauth_client.id,
              },
          }
        end

        it 'does not creates a identity provider' do
          expect { subject }.to_not(change { Osso::Models::IdentityProvider.count })
        end
      end

      describe 'with a service' do
        let(:variables) do
          {
            input:
              {
                enterpriseAccountId: target_account.id,
                service: 'OKTA',
                oauthClientId: oauth_client.id,
              },
          }
        end

        it 'does not creates a identity provider' do
          expect { subject }.to_not(change { Osso::Models::IdentityProvider.count })
        end
      end
    end
  end
end
