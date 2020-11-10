class AddSsoIssuerToIdentityProviders < ActiveRecord::Migration[6.0]
  def change
    add_column :identity_providers, :sso_issuer, :string

    Osso::Models::IdentityProvider.all.each do |idp|
      idp.sso_issuer = idp.root_url + "/" + idp.domain
      idp.save
    end

    change_column_null :identity_providers, :sso_issuer, false
  end
end
