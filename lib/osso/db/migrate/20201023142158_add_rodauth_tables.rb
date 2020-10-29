require 'rodauth/migrations'

class AddRodauthTables < ActiveRecord::Migration[6.0]
  def database_type
    'postgres'
  end

  def change
    enable_extension "citext"
    Rodauth.create_database_authentication_functions(self)
    Rodauth.create_database_previous_password_check_functions(self)

    create_table :accounts, id: :uuid do |t|
      t.citext :email, null: false, index: { unique: true, where: "status_id IN (1, 2)" }
      t.integer :status_id, null: false, default: 1
      t.string :role, null: false, default: 'admin'
    end

    add_reference :accounts, :oauth_client, type: :uuid, index: true

    create_table :account_password_hashes, id: :uuid do |t|
      t.foreign_key :accounts, column: :id
      t.string :password_hash, null: false
    end

    # Used by the password reset feature
    create_table :account_password_reset_keys, id: :uuid do |t|
      t.foreign_key :accounts, column: :id
      t.string :key, null: false
      t.datetime :deadline, null: false
      t.datetime :email_last_sent, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    # Used by the account verification feature
    create_table :account_verification_keys, id: :uuid do |t|
      t.string :key, null: false
      t.datetime :requested_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :email_last_sent, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    add_reference :account_verification_keys, :account, type: :uuid, index: true

    # Used by the remember me feature
    create_table :account_remember_keys, id: :uuid do |t|
      t.foreign_key :accounts, column: :id
      t.string :key, null: false
      t.datetime :deadline, null: false
    end
  end
end
