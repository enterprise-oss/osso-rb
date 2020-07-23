# frozen_string_literal: true

require 'spec_helper'

describe Osso::GraphQL::Schema do
  describe 'EnterpriseAccounts' do
    describe 'for an admin user' do
      let(:current_scope) { :admin }

      it 'returns Enterprise Accounts' do
        create_list(:enterprise_account, 2)

        query = <<~GRAPHQL
          query EnterpriseAccounts {
            enterpriseAccounts {
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

        response = described_class.execute(
          query,
          variables: nil,
          context: { scope: current_scope },
        )

        expect(response['errors']).to be_nil
        expect(response.dig('data', 'enterpriseAccounts').count).to eq(2)
      end
    end
  end
end
