module Rack
  module OAuth2
    class Server

      # Access token. This is what clients use to access resources.
      #
      # An access token is a unique code, associated with a client, an identity
      # and scope. It may be revoked, or expire after a certain period.
      class AccessToken
        include Ripple::Document
        property :code, String
        property :scope, String
        property :identity, String
        property :last_access, Integer
        property :prev_access, Integer
        property :revoked, Integer

        one :client, :class_name => 'Rack::OAuth2::Server::Client'

        # Creates a new AccessToken for the given client and scope.
        def self.create_token_for(client, scope)
          create(:code => Server.secure_random,
                 :scope => scope,
                 :client => client)
        end

        # Find AccessToken from token. Does not return revoked tokens.
        def self.from_token(token)
          if access = find(token) and !access.revoked
            return access
          end
        end

        # Get an access token (create new one if necessary).
        def self.get_token_for(identity, client, scope)
          if identity = Identity.find(identity)
            token = identity.access_tokens.find do |access_token|
              access_token.client.key == client.key and access_token.scope == scope
            end
          end

          token ||= create(:code => Server.secure_random,
                           :scope => scope,
                           :client => client,
                           :identity => identity)
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
