# frozen_string_literal: true

require 'spec_helper'

describe Osso::GraphQL::Schema do
  describe 'DeleteOauthClient' do
    let!(:oauth_client) { create(:oauth_client) }
    let(:variables) do
      {
        input: {
          id: oauth_client.id,
        },
      }
    end

    let(:mutation) do
      <<~GRAPHQL
         mutation DeleteOauthClient($input: DeleteOauthClientInput!) {
          deleteOauthClient(input: $input) {
            oauthClient {
              id
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
      it 'deletes the OauthClient' do
        expect { subject }.to change { Osso::Models::OauthClient.count }.by(-1)
      end
    end

    describe 'for an email scoped user' do
      let(:current_context) do 
        { scope: 'end-user', email: 'user@foo.com' }
      end

      it 'does not deletes the OauthClient' do
        expect { subject }.to_not(change { Osso::Models::OauthClient.count })
      end
    end
  end
end
