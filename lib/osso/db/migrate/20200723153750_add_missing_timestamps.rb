class AddMissingTimestamps < ActiveRecord::Migration[6.0]
  def change
    add_column :enterprise_accounts, :created_at, :timestamp
    add_column :enterprise_accounts, :updated_at, :timestamp
    update "UPDATE enterprise_accounts SET created_at = NOW(), updated_at = NOW()"    
    change_column_null :enterprise_accounts, :created_at, false
    change_column_null :enterprise_accounts, :updated_at, false


    add_column :identity_providers, :created_at, :timestamp
    add_column :identity_providers, :updated_at, :timestamp
    update "UPDATE enterprise_accounts SET created_at = NOW(), updated_at = NOW()"    
    change_column_null :enterprise_accounts, :created_at, false
    change_column_null :enterprise_accounts, :updated_at, false

    add_column :oauth_clients, :created_at, :timestamp
    add_column :oauth_clients, :updated_at, :timestamp
    update "UPDATE oauth_clients SET created_at = NOW(), updated_at = NOW()"    
    change_column_null :oauth_clients, :created_at, false
    change_column_null :oauth_clients, :updated_at, false

    add_column :redirect_uris, :created_at, :timestamp
    add_column :redirect_uris, :updated_at, :timestamp
    update "UPDATE redirect_uris SET created_at = NOW(), updated_at = NOW()"    
    change_column_null :redirect_uris, :created_at, false
    change_column_null :redirect_uris, :updated_at, false

    add_column :users, :created_at, :timestamp
    add_column :users, :updated_at, :timestamp
    update "UPDATE users SET created_at = NOW(), updated_at = NOW()"    
    change_column_null :users, :created_at, false
    change_column_null :users, :updated_at, false

  end
end
