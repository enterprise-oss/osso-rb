# frozen_string_literal: true

require 'spec_helper'

describe Osso::GraphQL::Schema do
  describe 'CreateIdentityProvider' do
    let(:domain) { Faker::Internet.domain_name }
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
        context: { scope: current_scope },
      )
    end

    describe 'for an admin user' do
      let(:current_scope) { :admin }
      it 'creates an Enterprise Account' do
        expect { subject }.to change { Osso::Models::EnterpriseAccount.count }.by(1)
        expect(subject.dig('data', 'createEnterpriseAccount', 'enterpriseAccount', 'domain')).
          to eq(domain)
      end
    end

    describe 'for an email scoped user' do
      let(:current_scope) { domain }

      it 'creates an Enterprise Account' do
        expect { subject }.to change { Osso::Models::EnterpriseAccount.count }.by(1)
        expect(subject.dig('data', 'createEnterpriseAccount', 'enterpriseAccount', 'domain')).
          to eq(domain)
      end
    end
    describe 'for the wrong email scoped user' do
      let(:current_scope) { 'foo.com' }

      it 'does not create an Enterprise Account' do
        expect { subject }.to_not(change { Osso::Models::EnterpriseAccount.count })
        expect(subject.dig('data', 'createEnterpriseAccount', 'enterpriseAccount', 'domain')).
          to be_nil
      end
    end
  end
end
