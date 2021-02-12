module Osso
  class Scim < Sinatra::Base
    include AppConfig
    register Sinatra::Namespace

    before do
      error 401 unless authorized?
    end

    namespace '/scim/v2' do
      get '/Users' do
        users = Models::User
        users = users.where(identity_provider: current_identity_provider)        
        users = users.where(ScimQueryParser.perform(params['filter'])) if params['filter']

        json scim_response(count: users.count, resources: users.first(10))
      end

      post '/Users' do
        user = Models::User.create(
          params[ScimSchema::SCHEMA_URI].symbolize_keys.merge(
            identity_provider: current_identity_provider
          )
        )

        # send webhook to app
        
        json created_scim_response(user)
      end

      get 'Users/:id' do

      end

      put 'Users/:id' do

      end

      patch 'Users/:id' do

      end

      get 'ServiceProviderConfig' do

      end

      get 'ResourceTypes' do

      end

      get 'Schemas' do

      end

      post 'Bulk' do

      end
    end

    private

    def scim_response(count: 0, resources: [])
      {
        "totalResults": count,
        "itemsPerPage":10,
        "startIndex":1,
        "schemas":[
           "urn:scim:schemas:core:1.0",
           ScimSchema::SCHEMA_URI,
        ],
        "Resources": resources,
     }
    end

    def created_scim_response(user)
      {
        "schemas":[
            "urn:scim:schemas:core:1.0",
            ScimSchema::SCHEMA_URI,
        ],
        "id": user.id,
        "userName": user.email,
      }
    end

    def authorized?
      true if current_identity_provider
    end

    def current_identity_provider
      return @current_identity_provider if defined?(@current_identity_provider)
      
      jwt = Base64.urlsafe_decode64(bearer_token)
      payload = JWT.decode(jwt, ENV['SESSION_SECRET'], 'HS256')[0]
      @current_identity_provider = Models::IdentityProvider.find_by(payload)
    end

    def bearer_token
      pattern = /^Bearer /
      header = request.env["HTTP_AUTHORIZATION"]
      header.gsub(pattern, '') if header&.match(pattern)
    end
  end
end
