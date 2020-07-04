# frozen_string_literal: true

class DropNullConstraintFromSamlProvidersProvider < ActiveRecord::Migration[6.0]
  def change
    change_column :saml_providers, :provider, :string, null: true
  end
end
