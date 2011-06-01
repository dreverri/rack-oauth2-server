module Rack
  module OAuth2
    class Server
      class AccessGrant
        include Ripple::Document

        property :code, String
        property :identity, String
        property :scope, String
        property :redirect_url, String
        property :created_at, Integer
        property :expires_at, Integer
        property :revoked, Integer
        property :access_token, String
        key_on :code

        one :client, :class_name => 'Rack::OAuth2::Server::Client'

        # Find AccessGrant from authentication code.
        def self.from_code(code)
          if grant = find(code) and !grant.revoked
            return grant
          end
        end

        # Create a new access grant.
        def self.create(identity, client, scope, redirect_uri = nil, expires = nil)
          created_at = Time.now.to_i

          super(:code => Server.secure_random,
                :identity => identity,
                :scope => scope,
                :redirect_uri => client.redirect_uri || redirect_uri,
                :created_at => created_at,
                :expires_at => created_at + (expires || 300),
                :client => client)
        end


        # Authorize access and return new access token.
        #
        # Access grant can only be redeemed once, but client can make multiple
        # requests to obtain it, so we need to make sure only first request is
        # successful in returning access token, futher requests raise
        # InvalidGrantError.
        def authorize!
          if self.access_token || self.revoked
            raise InvalidGrantError, "You can't use the same access grant twice"
          end

          self.access_token = AccessToken.get_token_for(self.identity, self.client, self.scope)
          save!
          self.access_token
        end

        def revoke!
          update_attributes(:revoked => Time.now.to_i)
        end
      end
    end
  end
end
