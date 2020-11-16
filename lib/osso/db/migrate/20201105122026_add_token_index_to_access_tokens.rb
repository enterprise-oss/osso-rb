class AddTokenIndexToAccessTokens < ActiveRecord::Migration[6.0]
  def change
    add_index :access_tokens, [:token, :expires_at], unique: true
  end
end
