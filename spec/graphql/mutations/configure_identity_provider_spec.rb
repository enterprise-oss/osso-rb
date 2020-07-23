# frozen_string_literal: true

require 'spec_helper'

describe Osso::GraphQL::Schema do
  describe 'ConfigureIdentityProvider' do
    let(:enterprise_account) { create(:enterprise_account) }
    let(:identity_provider) { create(:identity_provider, enterprise_account: enterprise_account) }
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
    let(:mutation) do
      <<~GRAPHQL
         mutation ConfigureIdentityProvider($input: ConfigureIdentityProviderInput!) {
          configureIdentityProvider(input: $input) {
            identityProvider {
              id
              domain
              status
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
      it 'configures an identity provider' do
        expect(subject.dig('data', 'configureIdentityProvider', 'identityProvider', 'status')).
          to eq('configured')
      end
    end

    describe 'for an email scoped user' do
      let(:domain) { Faker::Internet.domain_name }
      let(:current_scope) { domain }
      let(:enterprise_account) { create(:enterprise_account, domain: domain) }
      let(:identity_provider) { create(:identity_provider, enterprise_account: enterprise_account, domain: domain) }

      it 'configures an identity provider' do
        expect(subject.dig('data', 'configureIdentityProvider', 'identityProvider', 'domain')).
          to eq(domain)
      end
    end

    describe 'for the wrong email scoped user' do
      let(:domain) { Faker::Internet.domain_name }
      let(:current_scope) { domain }

      it 'does not configure an identity provider' do
        expect(subject.dig('errors')).to_not be_empty
      end
    end
  end
end
