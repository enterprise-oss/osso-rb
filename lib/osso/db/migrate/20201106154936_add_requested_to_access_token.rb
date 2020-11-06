class AddRequestedToAccessToken < ActiveRecord::Migration[6.0]
  def change
    add_column :access_tokens, :requested, :jsonb, default: '{}'
  end
end
