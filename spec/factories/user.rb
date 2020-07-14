# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: Osso::Models::User do
    id { SecureRandom.uuid }
    email { Faker::Internet.email }
    idp_id { SecureRandom.hex(32) }
    identity_provider { create(:okta_identity_provider) }
    enterprise_account
    after(:create) do |user|
      create(
        :authorization_code,
        user: user,
        redirect_uri: user.oauth_client.redirect_uri_values.sample,
      )
    end
  end
end
