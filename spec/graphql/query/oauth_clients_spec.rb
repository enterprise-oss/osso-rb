# frozen_string_literal: true

require 'spec_helper'

describe Osso::GraphQL::Schema do
  describe 'OAuthClients' do
    let(:query) do
      <<~GRAPHQL
        query OAuthClients {
          oauthClients {
            name
            id
            clientSecret
            clientId
          }
        }
      GRAPHQL
    end

    before do
      create_list(:oauth_client, 2)
    end

    subject do
      described_class.execute(
        query,
        variables: nil,
        context: current_context,
      )
    end

    describe 'for an admin user' do
      let(:current_context) do
        { scope: 'admin' }
      end

      it 'returns Oauth Clients' do
        expect(subject['errors']).to be_nil
        expect(subject.dig('data', 'oauthClients').count).to eq(2)
      end
    end

    describe 'for an internal scoped user' do
      let(:current_context) do
        { scope: 'internal' }
      end
      it 'does not return Oauth Clients' do
        expect(subject['errors']).to_not be_nil
        expect(subject.dig('data', 'oauthClients')).to be_nil
      end
    end
  end
end
