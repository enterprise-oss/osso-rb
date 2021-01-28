# frozen_string_literal: true

require 'spec_helper'

describe Osso::Admin do
  describe 'get /admin' do
    it 'renders the admin layout' do
      get('/admin')

      expect(last_response).to be_ok
    end
  end

  describe 'post /graphql' do
    let(:account) { create(:account) }

    it 'runs a GraphQL query with a valid jwt' do
      allow_any_instance_of(described_class.rodauth).to receive(:logged_in?).and_return(true)
      allow(Osso::Models::Account).to receive(:find).and_return(account)
      allow(Osso::GraphQL::Schema).to receive(:execute).and_return({ graphql: true })

      header 'Content-Type', 'application/json'
      post('/graphql')

      expect(last_response).to be_ok
      expect(last_json_response).to eq({ graphql: true })
    end

    it 'returns a 400 for an invalid jwt' do
      header 'Content-Type', 'application/json'
      header 'Authorization', 'Bearer bad-token'
      post('/graphql')

      expect(last_response.status).to eq 400
    end

    it 'returns a 401 without a jwt' do
      header 'Content-Type', 'application/json'
      post('/graphql')

      expect(last_response.status).to eq 401
    end
  end

  describe 'post /idp' do
    let(:domain) { Faker::Internet.domain_name }
    
    before do
      create(:configured_identity_provider, domain: domain)
    end

    it 'returns true when an available IDP is found' do
      header 'Content-Type', 'application/json'
      header 'Accept', 'application/json'
      post('/idp', { domain: domain }.to_json)

      expect(last_response).to be_ok
      expect(last_json_response).to eq({ onboarded: true })
    end

    it 'returns false when an available IDP is not found' do
      header 'Content-Type', 'application/json'
      header 'Accept', 'application/json'

      post('/idp', { domain: domain.reverse}.to_json)

      expect(last_response).to be_ok
      expect(last_json_response).to eq({ onboarded: false })
    end
  end
end
