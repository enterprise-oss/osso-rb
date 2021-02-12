module Osso
  class Scim < Sinatra::Base
    include AppConfig
    register Sinatra::Namespace

    namespace '/scim/v2' do
      before do
        error 401 unless authorized?
      end
      
      get '/Users' do
        users = Models::User
        users = users.where(identity_provider: current_identity_provider)        
        users = users.where(ScimQueryParser.perform(params['filter'])) if params['filter']

        json list_scim_response(count: users.count, resources: users.first(10))
      end

      post '/Users' do
        # OneLogin takes our custom schema and passes email and idp_id
        #
        # user = Models::User.create(
        #   params[ScimSchema::SCHEMA_URI].merge(
        #     identity_provider: current_identity_provider
        #   )
        # )

        # Okta does not support providing a custom schema template, but
        #  we can instruct Okta users to map attributes
        user = Models::User.create(
          email: params[:userName],
          idp_id: params[:userName],
          identity_provider: current_identity_provider,
        )

        # send webhook to app

        status 201
        json user_scim_response(user)
      rescue ActiveRecord::RecordNotUnique
        status 409
      end

      get '/Users/:id' do
        user = Models::User.find(params[:id])

        json user_scim_response(user)
      rescue
        status 404
        
        json ({
          detail: "No user for ID",
          schemas: [
            'urn:ietf:params:scim:api:messages:2.0:Error' # Okta
          ]
        })
      end

      put '/Users/:id' do

      end

      patch '/Users/:id' do

      end

      get '/Groups' do

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

    def list_scim_response(count: 0, resources: [])
      # TODO: seems this needs to be paginated, but a bit unclear
      {
        "totalResults": count,
        "itemsPerPage":10,
        "startIndex":1,
        "schemas":[
           "urn:scim:schemas:core:1.0",
           'urn:ietf:params:scim:api:messages:2.0:ListResponse', # Okta required
           ScimSchema::SCHEMA_URI
        ],
        "Resources": resources.map(&:as_scim_json),
     }
    end

    def user_scim_response(user)
      {
        "schemas":[
            "urn:scim:schemas:core:2.0",
            ScimSchema::SCHEMA_URI,
            "urn:ietf:params:scim:schemas:core:2.0:User" # okta
        ],
      }.merge(user.as_scim_json)
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
