class RemoveOauthClientIdFromEnterpriseAccounts < ActiveRecord::Migration[6.0]
  def up
    remove_reference :enterprise_accounts, :oauth_client, index: true
  end

  def down
    add_reference :enterprise_accounts, :oauth_client, type: :uuid, index: true
  end
end
