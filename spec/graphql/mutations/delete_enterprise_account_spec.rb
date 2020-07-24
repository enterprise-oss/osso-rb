# frozen_string_literal: true

require 'spec_helper'

describe Osso::GraphQL::Schema do
  describe 'DeleteEnterpriseAccount' do
    let(:domain) { Faker::Internet.domain_name }
    let!(:enterprise_account) { create(:enterprise_account, domain: domain) }
    let(:variables) do
      {
        input: {
          id: enterprise_account.id,
        },
      }
    end

    let(:mutation) do
      <<~GRAPHQL
         mutation DeleteEnterpriseAccount($input: DeleteEnterpriseAccountInput!) {
          deleteEnterpriseAccount(input: $input) {
            enterpriseAccount {
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
      it 'deletes an Enterprise Account' do
        expect { subject }.to change { Osso::Models::EnterpriseAccount.count }.by(-1)
        expect(subject.dig('data', 'createEnterpriseAccount', 'enterpriseAccount')).
          to be_nil
      end
    end

    describe 'for an email scoped user' do
      let(:current_scope) { domain }

      it 'deletes the Enterprise Account' do
        expect { subject }.to change { Osso::Models::EnterpriseAccount.count }.by(-1)
        expect(subject.dig('data', 'createEnterpriseAccount', 'enterpriseAccount')).
          to be_nil
      end
    end
    describe 'for the wrong email scoped user' do
      let(:current_scope) { 'foo.com' }

      it 'does not delete the Enterprise Account' do
        expect { subject }.to_not(change { Osso::Models::EnterpriseAccount.count })
      end
    end
  end
end
