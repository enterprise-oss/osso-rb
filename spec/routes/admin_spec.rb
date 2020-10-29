# frozen_string_literal: true

require 'spec_helper'

describe Osso::Admin do
  describe 'get /admin' do
    it 'redirects to /login without a session' do
      get('/admin')

      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to match('/login')
    end

    xit 'renders the admin page for a valid session token' do
      password = SecureRandom.urlsafe_base64(16)
      account = create(:verified_account, password: password)
      
      post('/login', { email: account.email, password: password })

      get('/admin')

      expect(last_response).to be_ok
    end
  end
end
