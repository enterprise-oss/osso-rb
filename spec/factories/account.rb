# frozen_string_literal: true

DB = Sequel.postgres(extensions: :activerecord_connection)

FactoryBot.define do
  factory :account, class: Osso::Models::Account do
    id { SecureRandom.uuid }
    email { Faker::Internet.email }
  end

  factory :verified_account, parent: :account do
    transient do
      password { SecureRandom.urlsafe_base64(8) }
    end
    status_id { 2 }

    after :create do |account|
      DB[:account_password_hashes].insert(
        id: account.id,
        password_hash: BCrypt::Password.create('secret', cost: BCrypt::Engine::MIN_COST).to_s,
      )
    end
  end
end
