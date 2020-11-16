# frozen_string_literal: true

require 'spec_helper'

describe Osso::Models::EnterpriseAccount do
  describe 'validates_domain' do
    it 'it returns false for an invalid domain' do
      customer = described_class.new(
        name: 'foo',
        domain: ' foo.com',
      )

      customer.save

      expect(customer.errors[:domain]).to include('is invalid')
    end
  end
end
