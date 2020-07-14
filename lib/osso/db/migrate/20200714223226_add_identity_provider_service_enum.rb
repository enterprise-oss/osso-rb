class AddIdentityProviderServiceEnum < ActiveRecord::Migration[6.0]
  def change
    def up
      execute <<-SQL
        CREATE TYPE identity_provider_service AS ENUM ('OKTA', 'AZURE');
      SQL
      chnage_column :identity_providers, :service, :identity_provider_service
    end
  
    def down
      chnage_column :identity_providers, :service, :text
      execute <<-SQL
        DROP TYPE identity_provider_service;
      SQL
    end
  end
end
