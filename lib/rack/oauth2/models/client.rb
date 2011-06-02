module Rack
  module OAuth2
    class Server
      class Client
        include Ripple::Document
        timestamps!

        # Client identifier.
        property :id, String
        # Client secret: random, long, and hexy.
        property :secret, String
        # User see this.
        property :display_name, String
        # Link to client's Web site.
        property :link, String
        # Preferred image URL for this icon.
        property :image_url, String
        # Redirect URL. Supplied by the client if they want to
        # restrict redirect URLs (better security).
        property :redirect_uri, String
        # List of scope the client is allowed to request.
        property :scope, Array
        # Free form fields for internal use.
        property :notes, String
        # Timestamp if revoked.
        property :revoked, Integer
        key_on :id

        before_create :generate_id, :generate_secret

        def generate_id
          self.id = Server.secure_random if self.id.nil?
        end

        def generate_secret
          self.secret = Server.secure_random if self.secret.nil?
        end

        def scope=(value)
          self[:scope] = Utils.normalize_scope(value)
        end

        # Revoke all authorization requests, access grants and access
        # tokens for this client. Ward off the evil.
        def revoke!
          # TODO: revoke all requests and tokens
          update_attributes(:revoked => Time.now.to_i)
        end

        def update(args)
          update_attributes(args)
          self
        end
      end
    end
  end
end
