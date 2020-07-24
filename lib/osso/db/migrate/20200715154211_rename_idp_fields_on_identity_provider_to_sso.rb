class RenameIdpFieldsOnIdentityProviderToSso < ActiveRecord::Migration[6.0]
  def change
    rename_column :identity_providers, :idp_cert, :sso_cert
    rename_column :identity_providers, :idp_sso_target_url, :sso_url
  end
end
