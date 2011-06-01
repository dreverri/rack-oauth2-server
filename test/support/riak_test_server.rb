require 'riak/test_server'

module Ripple
  module TestServer
    extend self

    # Tweak this to change how your test server is configured
    def test_server_config
      {
        :app_config => {
          :riak_kv => {
            :map_cache_size => 0, # 0.14
            :vnode_cache_entries => 0 # 0.13
          },
          :riak_core => { :web_port => Ripple.config[:http_port] || 8098 }
        },
        :bin_dir => Ripple.config.delete(:bin_dir),
        :temp_dir => Ripple.config.delete(:temp_dir),
      }
    end

    def test_unit_defined?
      Object.const_defined?(:Test) && Test.const_defined?(:Unit)
    end

    # Prepares the subprocess Riak node for the test suite
    def setup
      unless @test_server
        begin
          _server = @test_server = Riak::TestServer.new(test_server_config)
          @test_server.prepare!
          @test_server.start
          at_exit { _server.cleanup if test_unit_defined? and Test::Unit.run? }
        rescue => e
          warn <<-EOS

Can't start Ripple::TestServer. Specify the location of your Riak
installation in config/ripple.yml.

EOS
          warn e.inspect
          @test_server = nil
        end
      end
    end

    def cleanup
      @test_server.cleanup
    end

    # Clear the data after each test run
    def clear
      @test_server.recycle if @test_server
    end
  end
end

Ripple::TestServer.setup
