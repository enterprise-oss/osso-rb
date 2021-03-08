module Osso
  module ScimSchema
    SCHEMA_URI = 'urn:scim:osso:default:schema'
    def user_schema
      {
        schemas: ["urn:scim:schemas:core:1.0", SCHEMA_URI],
        userName: "{$user.email}",
        SCHEMA_URI: {
          idp_id: "{$user.id}",
          email: "{$user.email}"
        }
      }.to_json
    end  
  end
end