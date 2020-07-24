class AddIdentityProviderStatusEnumAndUseOnIdentityProviders < ActiveRecord::Migration[6.0]
  def up
    execute <<~SQL
      CREATE TYPE identity_provider_status AS ENUM ('PENDING', 'CONFIGURED', 'ACTIVE', 'ERROR');
    SQL
    add_column :identity_providers, :status, :identity_provider_status, default: 'PENDING'
  end

  def down
    remove_column :identity_providers, :status
    execute <<~SQL
      DROP TYPE identity_provider_status;
    SQL
  end
end
