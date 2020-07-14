class CreateIdentityProviders < ActiveRecord::Migration[6.0]
  def change
    create_table :identity_providers, id: :uuid do |t|
      t.string  :service
      t.string  :domain, null: false
      t.string :idp_sso_target_url
      t.text :idp_cert
    end

    add_index :identity_providers, :domain
  end
end
