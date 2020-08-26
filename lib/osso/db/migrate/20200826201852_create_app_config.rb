class CreateAppConfig < ActiveRecord::Migration[6.0]
  def change
    create_table :app_configs, id: :uuid do |t|
      t.string :contact_email
      t.string :logo_url
      t.string :name
      
      t.timestamps
    end
  end
end
