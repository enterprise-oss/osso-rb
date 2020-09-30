class AddUsersCountToIdentityProvidersAndEnterpriseAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :enterprise_accounts, :users_count, :integer, default: 0
    add_column :identity_providers, :users_count, :integer, default: 0
  end
end
