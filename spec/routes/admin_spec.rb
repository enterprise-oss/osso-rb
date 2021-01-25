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
end
