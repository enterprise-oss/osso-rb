class AddRequestedToAuthorizationCodesAndAccessTokens < ActiveRecord::Migration[6.0]
  def change
    add_column :access_tokens, :requested, :jsonb, default: {}
    add_column :authorization_codes, :requested, :jsonb, default: {}
  end
end
