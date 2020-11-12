class AddPingToIdentityProviderServiceEnum < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def up
    execute <<-SQL
      ALTER TYPE identity_provider_service ADD VALUE 'PING';
    SQL
  end
  
  def down
    execute <<~SQL
      CREATE TYPE identity_provider_service_new AS ENUM ('AZURE', 'OKTA', 'ONELOGIN', 'GOOGLE');

      -- Remove values that won't be compatible with new definition
      DELETE FROM identity_providers WHERE service = 'PING';
      
      -- Convert to new type, casting via text representation
      ALTER TABLE identity_providers 
        ALTER COLUMN service TYPE identity_provider_service_new 
          USING (service::text::identity_provider_service_new);
      
      -- and swap the types
      DROP TYPE identity_provider_service;
      
      ALTER TYPE identity_provider_service_new RENAME TO identity_provider_service;
    SQL
  end
end
