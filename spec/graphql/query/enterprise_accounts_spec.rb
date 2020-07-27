# frozen_string_literal: true

require 'spec_helper'

describe Osso::GraphQL::Schema do
  describe 'EnterpriseAccounts' do
    describe 'for an admin user' do
      let(:current_scope) { :admin }

      it 'returns paginated Enterprise Accounts' do
        %w[A B C].map do |name|
          create(:enterprise_account, name: name)
        end

        query = <<~GRAPHQL
          query EnterpriseAccounts($first: Int, $sortColumn: String, $sortOrder: String) {
            enterpriseAccounts(first: $first, sortColumn: $sortColumn, sortOrder: $sortOrder) {
              pageInfo {
                hasNextPage
                endCursor
              }
              totalCount
              edges {
                node {
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
            }
          }
        GRAPHQL

        response = described_class.execute(
          query,
          variables: { first: 2, sortOrder: 'descending', sortColumn: 'name' },
          context: { scope: current_scope },
        )

        expect(response['errors']).to be_nil
        expect(response.dig('data', 'enterpriseAccounts', 'edges').count).to eq(2)
        expect(response.dig('data', 'enterpriseAccounts', 'edges', 0, 'node', 'name')).to eq('C')
        expect(response.dig('data', 'enterpriseAccounts', 'totalCount')).to eq(3)
        expect(response.dig('data', 'enterpriseAccounts', 'pageInfo', 'hasNextPage')).to eq(true)
      end
    end
  end
end
