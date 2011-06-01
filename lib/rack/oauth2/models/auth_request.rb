module Rack
  module OAuth2
    class Server
      # Authorization request. Represents request on behalf of client to access
      # particular scope. Use this to keep state from incoming authorization
      # request to grant/deny redirect.
      class AuthRequest
        include Ripple::Document

        # scope of this request: array of names.
        property :scope, String
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

        # Create a new authorization request. This holds state, so in addition
        # to client ID and scope, we need to know the URL to redirect back to
        # and any state value to pass back in that redirect.
        def self.create(client, scope, redirect_uri, response_type, state)
        end

        # Grant access to the specified identity.
        def grant!(identity)
        end

        # Deny access.
        def deny!
        end
      end
    end
  end
end
