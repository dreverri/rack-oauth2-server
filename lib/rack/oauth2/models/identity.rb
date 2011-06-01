module Rack
  module OAuth2
    class Server
      class Identity
        include Ripple::Document

        property :key, String
        key_on :key

        many :access_tokens, :class_name => 'Rack::OAuth2::Server::AccessTokens'
      end
    end
  end
end
