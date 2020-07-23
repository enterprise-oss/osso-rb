# frozen_string_literal: true

require 'spec_helper'

describe Osso::GraphQL::Schema do
  describe 'EnterpriseAccount' do
    let(:domain) { Faker::Internet.domain_name }
    let(:variables) { { domain: domain } }
    let(:query) do
      <<~GRAPHQL
        query EnterpriseAccount($domain: String!) {
          enterpriseAccount(domain: $domain) {
            domain
              id
              identityProviders {
                id
                service
                domain
                acsUrl
                ssoCert
                ssoUrl
                status
              }
              name
              status
            }
        }
      GRAPHQL
    end

    before do
      create(:enterprise_account)
      create(:enterprise_account, domain: domain)
    end

    subject do
      described_class.execute(
        query,
        variables: variables,
        context: { scope: current_scope },
      )
    end

    describe 'for an admin user' do
      let(:current_scope) { :admin }
      it 'returns Enterprise Account for domain' do
        expect(subject['errors']).to be_nil
        expect(subject.dig('data', 'enterpriseAccount', 'domain')).to eq(domain)
      end
    end

    describe 'for an email scoped user' do
      let(:current_scope) { domain }
      it 'returns Enterprise Account for domain' do
        expect(subject['errors']).to be_nil
        expect(subject.dig('data', 'enterpriseAccount', 'domain')).to eq(domain)
      end
    end

    describe 'for the wrong email scoped user' do
      let(:current_scope) { 'bar.com' }
      it 'returns Enterprise Account for domain' do
        expect(subject['errors']).to be_nil
        expect(subject.dig('data', 'enterpriseAccount')).to be_nil
      end
    end
  end
end
