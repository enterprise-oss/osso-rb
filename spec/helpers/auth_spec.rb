# frozen_string_literal: true

require 'spec_helper'

describe Osso::Helpers::Auth do
  before do
    ENV['JWT_HMAC_SECRET'] = 'super-secret'
  end

  subject(:app) do
    Class.new do
      include Osso::Helpers::Auth
    end
  end

  describe 'with the token as a header' do
    before do
      allow_any_instance_of(subject).to receive(:request) do
        double('Request', env: { 'HTTP_AUTHORIZATION' => token }, post?: false)
      end

      allow_any_instance_of(subject).to receive(:session) do
        {
          admin_token: nil,
        }
      end

      allow_any_instance_of(subject).to receive(:redirect) do
        false
      end
    end

    describe 'with an admin token' do
      let(:token) { encode({ scope: 'admin' }) }

      it 'allows #token_protected! methods' do
        expect(subject.new.token_protected!).to_not be(false)
      end

      it 'allows #enterprise_protected! methods' do
        expect(subject.new.enterprise_protected!).to_not be(false)
      end

      it 'allows #internal_protected! methods' do
        expect(subject.new.internal_protected!).to_not be(false)
      end

      it 'allows #admin_protected! methods' do
        expect(subject.new.admin_protected!).to_not be(false)
      end
    end

    describe 'with an internal token' do
      let(:token) { encode({ scope: 'internal' }) }

      it 'allows #token_protected! methods' do
        expect(subject.new.token_protected!).to_not be(false)
      end

      it 'allows #enterprise_protected! methods' do
        expect(subject.new.enterprise_protected!).to_not be(false)
      end

      it 'allows #internal_protected! methods' do
        expect(subject.new.internal_protected!).to_not be(false)
      end

      it 'allows #admin_protected! methods' do
        expect(subject.new.admin_protected!).to be(false)
      end
    end

    describe 'with an end-user token' do
      let(:token) { encode({ scope: 'end-user', email: 'user@example.com' }) }

      it 'allows #token_protected! methods' do
        expect(subject.new.token_protected!).to_not be(false)
      end

      it 'allows #enterprise_protected! methods for the scoped domain' do
        expect(subject.new.enterprise_protected!('example.com')).to_not be(false)
      end

      it 'halts #enterprise_protected! methods for the wrong scoped domain' do
        expect(subject.new.enterprise_protected!('foo.com')).to be(false)
      end

      it 'halts #internal_protected! methods' do
        expect(subject.new.internal_protected!).to be(false)
      end

      it 'halts #admin_protected! methods' do
        expect(subject.new.admin_protected!).to be(false)
      end
    end
  end

  describe 'with the token as a parameter' do
    before do
      allow_any_instance_of(subject).to receive(:request) do
        double('Request', env: {}, params: { 'admin_token' => token }, post?: false)
      end

      allow_any_instance_of(subject).to receive(:session) do
        {
          admin_token: nil,
        }
      end

      allow_any_instance_of(subject).to receive(:redirect) do
        false
      end
    end

    describe 'with an admin token' do
      let(:token) { encode({ scope: 'admin' }) }

      it 'allows #token_protected! methods' do
        expect(subject.new.token_protected!).to_not be(false)
      end

      it 'allows #enterprise_protected! methods' do
        expect(subject.new.enterprise_protected!).to_not be(false)
      end

      it 'allows #internal_protected! methods' do
        expect(subject.new.internal_protected!).to_not be(false)
      end

      it 'allows #admin_protected! methods' do
        expect(subject.new.admin_protected!).to_not be(false)
      end
    end

    describe 'with an internal token' do
      let(:token) { encode({ scope: 'internal' }) }

      it 'allows #token_protected! methods' do
        expect(subject.new.token_protected!).to_not be(false)
      end

      it 'allows #enterprise_protected! methods' do
        expect(subject.new.enterprise_protected!).to_not be(false)
      end

      it 'allows #internal_protected! methods' do
        expect(subject.new.internal_protected!).to_not be(false)
      end

      it 'allows #admin_protected! methods' do
        expect(subject.new.admin_protected!).to be(false)
      end
    end

    describe 'with an end-user token' do
      let(:token) { encode({ scope: 'end-user', email: 'user@example.com' }) }

      it 'allows #token_protected! methods' do
        expect(subject.new.token_protected!).to_not be(false)
      end

      it 'allows #enterprise_protected! methods for the scoped domain' do
        expect(subject.new.enterprise_protected!('example.com')).to_not be(false)
      end

      it 'halts #enterprise_protected! methods for the wrong scoped domain' do
        expect(subject.new.enterprise_protected!('foo.com')).to be(false)
      end

      it 'halts #internal_protected! methods' do
        expect(subject.new.internal_protected!).to be(false)
      end

      it 'halts #admin_protected! methods' do
        expect(subject.new.admin_protected!).to be(false)
      end
    end
  end

  describe 'with the token in session' do
    before do
      allow_any_instance_of(subject).to receive(:request) do
        double('Request', env: {}, params: {}, post?: false)
      end

      allow_any_instance_of(subject).to receive(:redirect) do
        false
      end

      allow_any_instance_of(subject).to receive(:session).and_return(
        { admin_token: token }.with_indifferent_access,
      )
    end

    describe 'with an admin token' do
      let(:token) { encode({ scope: 'admin' }) }

      it 'allows #token_protected! methods' do
        expect(subject.new.token_protected!).to_not be(false)
      end

      it 'allows #enterprise_protected! methods' do
        expect(subject.new.enterprise_protected!).to_not be(false)
      end

      it 'allows #internal_protected! methods' do
        expect(subject.new.internal_protected!).to_not be(false)
      end

      it 'allows #admin_protected! methods' do
        expect(subject.new.admin_protected!).to_not be(false)
      end
    end

    describe 'with an internal token' do
      let(:token) { encode({ scope: 'internal' }) }

      it 'allows #token_protected! methods' do
        expect(subject.new.token_protected!).to_not be(false)
      end

      it 'allows #enterprise_protected! methods' do
        expect(subject.new.enterprise_protected!).to_not be(false)
      end

      it 'allows #internal_protected! methods' do
        expect(subject.new.internal_protected!).to_not be(false)
      end

      it 'allows #admin_protected! methods' do
        expect(subject.new.admin_protected!).to be(false)
      end
    end

    describe 'with an end-user token' do
      let(:token) { encode({ scope: 'end-user', email: 'user@example.com' }) }

      it 'allows #token_protected! methods' do
        expect(subject.new.token_protected!).to_not be(false)
      end

      it 'allows #enterprise_protected! methods for the scoped domain' do
        expect(subject.new.enterprise_protected!('example.com')).to_not be(false)
      end

      it 'halts #enterprise_protected! methods for the wrong scoped domain' do
        expect(subject.new.enterprise_protected!('foo.com')).to be(false)
      end

      it 'halts #internal_protected! methods' do
        expect(subject.new.internal_protected!).to be(false)
      end

      it 'halts #admin_protected! methods' do
        expect(subject.new.admin_protected!).to be(false)
      end
    end
  end

  def encode(payload)
    JWT.encode(
      payload,
      ENV['JWT_HMAC_SECRET'],
      'HS256',
    )
  end
end
