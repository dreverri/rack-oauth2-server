module Rack
  module OAuth2
    class Server
      class AccessGrant
        include Ripple::Document
        timestamps!

        property :code, String
        property :identity, String
        property :scope, Array
        property :redirect_uri, String
        property :expires_at, Integer
        property :revoked, Integer
        key_on :code

        one :client, :class_name => 'Rack::OAuth2::Server::Client'
        one :access_token, :class_name => 'Rack::OAuth2::Server::AccessToken'

        def scope=(value)
          self[:scope] = Utils.normalize_scope(value)
        end

        def client_id
          self.client.id
        end

        # Find AccessGrant from authentication code.
        def self.from_code(code)
          if grant = find(code) and !grant.revoked
            return grant
          end
        end

        # Create a new access grant.
        def self.create(identity, client, scope, redirect_uri = nil, expires = nil)
          grant = new(:code => Server.secure_random,
                      :identity => identity,
                      :scope => scope,
                      :redirect_uri => client.redirect_uri || redirect_uri,
                      :expires_at => Time.now.to_i + (expires || 300),
                      :client => client)
          grant.save
          grant
        end


        # Authorize access and return new access token.
        #
        # Access grant can only be redeemed once, but client can make multiple
        # requests to obtain it, so we need to make sure only first request is
        # successful in returning access token, futher requests raise
        # InvalidGrantError.
        def authorize!
          if !!self.access_token || !!self.revoked
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
