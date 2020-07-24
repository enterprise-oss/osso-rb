# frozen_string_literal: true

require 'spec_helper'

describe Osso::GraphQL::Schema do
  describe 'CreateOauthClient' do
    let(:variables) do
      {
        input: {
          name: Faker::Company.name,
        },
      }
    end

    let(:mutation) do
      <<~GRAPHQL
         mutation CreateOauthClient($input: CreateOauthClientInput!) {
          createOauthClient(input: $input) {
            oauthClient {
              id
              name
              clientId
              clientSecret
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
      it 'creates an OauthClient' do
        expect { subject }.to change { Osso::Models::OauthClient.count }.by(1)
        expect(subject.dig('data', 'createOauthClient', 'oauthClient', 'clientId')).
          to_not be_nil
      end
    end

    describe 'for an email scoped user' do
      let(:current_scope) { 'foo.com' }

      it 'does not create an OauthClient Account' do
        expect { subject }.to_not(change { Osso::Models::OauthClient.count })
      end
    end
  end
end
