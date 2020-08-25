# frozen_string_literal: true

require 'spec_helper'

describe Osso::GraphQL::Schema do
  describe 'CreateIdentityProvider' do
    let(:domain) { Faker::Internet.domain_name }
    let!(:oauth_client) { create(:oauth_client) }
    let(:variables) do
      {
        input: {
          name: Faker::Company.name,
          domain: domain,
        },
      }
    end

    let(:mutation) do
      <<~GRAPHQL
         mutation CreateEnterpriseAccount($input: CreateEnterpriseAccountInput!) {
          createEnterpriseAccount(input: $input) {
            enterpriseAccount {
              id
              domain
              name
              status
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
      let(:variables) do
        {
          input: {
            name: Faker::Company.name,
            domain: domain,
            oauthClientId: oauth_client.id,
          },
        }
      end

      it 'creates an Enterprise Account' do
        expect { subject }.to change { Osso::Models::EnterpriseAccount.count }.by(1)
        expect(subject.dig('data', 'createEnterpriseAccount', 'enterpriseAccount', 'domain')).
          to eq(domain)
      end

      it 'attaches the Enterprise Account to the correct OAuth Client' do
        expect { subject }.to change { oauth_client.enterprise_accounts.count }.by(1)
      end
    end

    describe 'for an internal scoped user' do
      let(:current_context) do
        {
          scope: 'internal',
          email: "user@saasco.com",
          oauth_client_id: oauth_client.identifier,
        }
      end

      it 'creates an Enterprise Account' do
        expect { subject }.to change { Osso::Models::EnterpriseAccount.count }.by(1)
        expect(subject.dig('data', 'createEnterpriseAccount', 'enterpriseAccount', 'domain')).
          to eq(domain)
      end

      it 'attaches the Enterprise Account to the correct OAuth Client' do
        expect { subject }.to change { oauth_client.enterprise_accounts.count }.by(1)
      end
    end

    describe 'for an email scoped user' do
      let(:current_context) do
        {
          scope: 'end-user',
          email: "user@#{domain}",
          oauth_client_id: oauth_client.identifier,
        }
      end

      it 'creates an Enterprise Account' do
        expect { subject }.to change { Osso::Models::EnterpriseAccount.count }.by(1)
        expect(subject.dig('data', 'createEnterpriseAccount', 'enterpriseAccount', 'domain')).
          to eq(domain)
      end

      it 'attaches the Enterprise Account to the correct OAuth Client' do
        expect { subject }.to change { oauth_client.enterprise_accounts.count }.by(1)
      end
    end
    describe 'for the wrong email scoped user' do
      let(:current_context) do
        { scope: 'end-user', email: 'user@foo.com' }
      end

      it 'does not create an Enterprise Account' do
        expect { subject }.to_not(change { Osso::Models::EnterpriseAccount.count })
        expect(subject.dig('data', 'createEnterpriseAccount', 'enterpriseAccount', 'domain')).
          to be_nil
      end
    end
  end
end
