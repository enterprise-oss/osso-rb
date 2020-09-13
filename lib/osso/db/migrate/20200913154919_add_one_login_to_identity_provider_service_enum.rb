class AddOneLoginToIdentityProviderServiceEnum < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      ALTER TYPE identity_provider_service ADD VALUE 'ONELOGIN';
    SQL
  end
  def down
    execute <<-SQL
      ALTER TYPE identity_provider_service REMOVE VALUE 'ONELOGIN';
    SQL
  end
end
