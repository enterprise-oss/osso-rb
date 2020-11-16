# frozen_string_literal: true

require 'spec_helper'

describe Osso::GraphQL::Schema do
  describe 'Identity Provider' do
    let(:id) { Faker::Internet.uuid }
    let(:domain) { Faker::Internet.domain_name }
    let(:variables) { { id: id } }
    let(:query) do
      <<-GRAPHQL
        query IdentityProvider($id: ID!) {
          identityProvider(id: $id) {
            id
            service
            domain
            acsUrl
            acsUrlValidator
            ssoCert
            ssoUrl
            status
          }
        }
      GRAPHQL
    end

    before do
      create(:identity_provider)
      create(:identity_provider, id: id, domain: domain)
    end

    subject do
      described_class.execute(
        query,
        variables: variables,
        context: current_context,
      )
    end

    describe 'for an admin user' do
      let(:current_context) do
        { scope: 'admin' }
      end
      it 'returns Identity Provider for id' do
        expect(subject['errors']).to be_nil
        expect(subject.dig('data', 'identityProvider', 'id')).to eq(id)
      end
    end

    describe 'for an email scoped user' do
      let(:current_context) do
        {
          scope: 'end-user',
          email: "user@#{domain}",
        }
      end
      it 'returns Enterprise Account for domain' do
        expect(subject['errors']).to be_nil
        expect(subject.dig('data', 'identityProvider', 'domain')).to eq(domain)
      end
    end

    describe 'for the wrong email scoped user' do
      let(:current_context) do
        {
          scope: 'end-user',
          email: 'user@bar.com',
        }
      end
      it 'returns Enterprise Account for domain' do
        expect(subject['errors']).to_not be_empty
        expect(subject.dig('data', 'enterpriseAccount')).to be_nil
      end
    end
  end
end
