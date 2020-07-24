class AddProviderIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :identity_provider_id, :uuid

    add_foreign_key :users, :identity_providers
  end
end
