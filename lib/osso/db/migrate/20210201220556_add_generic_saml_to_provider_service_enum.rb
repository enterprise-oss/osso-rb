class AddGenericSamlToProviderServiceEnum < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    execute <<-SQL
      ALTER TYPE identity_provider_service ADD VALUE 'OTHER';
    SQL
  end
  
  def down
    execute <<~SQL
      CREATE TYPE identity_provider_service_new AS ENUM ('AZURE', 'OKTA', 'ONELOGIN', 'GOOGLE', 'PING', 'SALESFORCE');

      -- Remove values that won't be compatible with new definition
      DELETE FROM identity_providers WHERE service = 'OTHER';
      
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
