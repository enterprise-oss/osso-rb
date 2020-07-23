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
        context: { scope: current_scope },
      )
    end

    describe 'for an admin user' do
      let(:current_scope) { :admin }
      it 'deletes the OauthClient' do
        expect { subject }.to change { Osso::Models::OauthClient.count }.by(-1)
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
