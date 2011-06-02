module Rack
  module OAuth2
    class Server
      # Authorization request. Represents request on behalf of client to access
      # particular scope. Use this to keep state from incoming authorization
      # request to grant/deny redirect.
      class AuthRequest
        include Ripple::Document
        timestamps!

        # scope of this request: array of names.
        property :scope, Array
        # Redirect back to this URL.
        property :redirect_uri, String
        # Client requested we return state on redirect.
        property :state, String
        # Response type: either code or token.
        property :response_type, String
        # If granted, the access grant code.
        property :grant_code, String
        # If granted, the access token.
        property :access_token, String
        # Keeping track of things.
        property :authorized_at, Integer
        # Timestamp if revoked.
        property :revoked, Integer

        one :client, :class_name => 'Rack::OAuth2::Server::Client'

        def scope=(value)
          self[:scope] = Utils.normalize_scope(value)
        end

        def id
          self.key
        end

        def client_id
          self.client.id
        end

        # Create a new authorization request. This holds state, so in addition
        # to client ID and scope, we need to know the URL to redirect back to
        # and any state value to pass back in that redirect.
        def self.create(client, scope, redirect_uri, response_type, state)
          req = new(:client => client,
                    :scope => scope,
                    :redirect_uri => client.redirect_uri || redirect_uri,
                    :response_type=>response_type,
                    :state=>state)
          req.save
          req
        end

        def revoked?
          !!self.revoked or !!self.client.revoked
        end

        # Grant access to the specified identity.
        def grant!(identity)
          return false if revoked?
          self.authorized_at = Time.now.to_i
          if response_type == "code" # Requested authorization code
            access_grant = AccessGrant.create(identity, self.client, self.scope, self.redirect_uri)
            self.grant_code = access_grant.code
          else # Requested access token
            access_token = AccessToken.get_token_for(identity, self.client, self.scope)
            self.access_token = access_token.token
          end
          save
        end

        # Deny access.
        def deny!
          now = Time.now.to_i
          update_attributes(:revoked => now, :authorized_at => now)
        end
      end
    end
  end
end
