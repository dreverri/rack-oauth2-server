module Rack
  module OAuth2
    class Server
      class Identity
        include Ripple::Document

        many :access_tokens, :class_name => 'Rack::OAuth2::Server::AccessToken'

        def get_token_for(client, scope)
          scope = Utils.normalize_scope(scope)
          token = self.access_tokens.find do |access_token|
            access_token.client.id == client.id and
              access_token.scope == scope
          end

          unless token
            token = self.access_tokens.build(:code => Server.secure_random,
                                             :scope => scope,
                                             :client => client,
                                             :identity => self.key)
            self.save
          end
          token
        end
      end
    end
  end
end
