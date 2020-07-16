class AddNameToEnterpriseAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :enterprise_accounts, :name, :string, null: false
  end
end
