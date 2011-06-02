module Rack
  module OAuth2
    class Server
      # Access token. This is what clients use to access resources.
      #
      # An access token is a unique code, associated with a client, an identity
      # and scope. It may be revoked, or expire after a certain period.
      class AccessToken
        include Ripple::Document
        timestamps!

        property :code, String
        property :scope, Array
        property :identity, String
        property :last_access, Integer
        property :prev_access, Integer
        property :revoked, Integer
        property :expires_at, Integer
        key_on :code

        one :client, :class_name => 'Rack::OAuth2::Server::Client'

        def token
          self.code
        end

        def client_id
          self.client.id
        end

        def scope=(value)
          self[:scope] = Utils.normalize_scope(value)
        end

        # Creates a new AccessToken for the given client and scope.
        def self.create_token_for(client, scope)
          # TODO: this seems like an unneccessary method
          create(:code => Server.secure_random,
                 :scope => scope,
                 :client => client)
        end

        # Find AccessToken from token. Does not return revoked tokens.
        def self.from_token(token)
          if access = find(token) and !access.revoked and !access.client.revoked
            return access
          end
        end

        # Get an access token (create new one if necessary).
        def self.get_token_for(identity, client, scope)
          unless ident = Identity.find(identity)
            ident = Identity.new
            ident.key = identity
          end

          ident.get_token_for(client, scope)
        end

        # Find all AccessTokens for an identity.
        def self.from_identity(identity)
          if identity = Identity.find(identity)
            identity.access_tokens
          end
        end

        # Returns all access tokens for a given client, Use limit and offset
        # to return a subset of tokens, sorted by creation date.
        def self.for_client(client_id, offset = 0, limit = 100)
          # Skip
        end

        def self.historical(filter = {})
          # Skip
        end

        # Updates the last access timestamp.
        def access!
          today = (Time.now.to_i / 3600) * 3600
          if self.last_access.nil? || self.last_access < today
            self.prev_access = self.last_access
            self.last_access = today
            save!
          end
        end

        # Revokes this access token.
        def revoke!
          update_attributes(:revoked => Time.now.to_i)
        end
      end
    end
  end
end
