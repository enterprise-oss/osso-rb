class AddOauthClientIdToEnterpriseAccountsAndIdentityProviders < ActiveRecord::Migration[6.0]
  def change
    add_reference :enterprise_accounts, :oauth_client, type: :uuid, index: true
    add_reference :identity_providers, :oauth_client, type: :uuid, index: true
  end
end
