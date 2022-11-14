# This whole resource type is a weird experimental hack to get the API
# credentials into the catalog without writing them plaintext to disk
# somewhere. It should almost certainly be replaced by a file in /etc like all
# the other similar modules (like the AWS module) do.

require 'retries' if Puppet.features.retries?
require 'httparty' if Puppet.features.httparty?

Puppet::Type.type(:graylog_api).provide(:graylog_api) do

  confine feature: :retries
  confine feature: :httparty

  # Once the resource is in the catalog, we're guaranteed to get a call to
  # prefetch, which gets passed the configured resource attributes. There's no
  # concrete resource to manage in the first place, but we take this
  # opportunity to cache the credentials we need in a central location so that
  # they can be used by other resource types to connect to the API, without
  # having to write them to disk.
  def self.prefetch(resources)
    password = resources[:api][:password]
    port = resources[:api][:port]
    username = resources[:api][:username]
    tls = resources[:api][:tls]
    server = resources[:api][:server]
    verify_tls = resources[:api][:verify_tls]
    ssl_ca_file = resources[:api][:ssl_ca_file]
    Puppet::Provider::GraylogAPI.api_password = password
    Puppet::Provider::GraylogAPI.api_port = port
    Puppet::Provider::GraylogAPI.api_tls = tls
    Puppet::Provider::GraylogAPI.api_server = server
    Puppet::Provider::GraylogAPI.verify_tls = verify_tls
    Puppet::Provider::GraylogAPI.ssl_ca_file = ssl_ca_file
    wait_for_api(port, server)
    resources[:api].provider = new({password: password, port: port, username: username, tls: tls, server: server, verify_tls: verify_tls, ssl_ca_file: ssl_ca_file})
  end

  # We also make sure that the Graylog server is actually up and responding
  # before allowing catalog application to proceed any further.
  def self.wait_for_api(port, server)
    scheme = Puppet::Provider::GraylogAPI.api_tls ? 'https' : 'http'
    tls_opts = Puppet::Provider::GraylogAPI.tls_opts
    Puppet.debug("Waiting for Graylog API")
    with_retries(max_tries: 60, base_sleep_seconds: 1, max_sleep_seconds: 1) do
      HTTParty.head("#{scheme}://#{server}:#{port}", **tls_opts)
    end
  rescue Errno::ECONNREFUSED
    fail("Graylog API didn't become available on #{server} port #{port} after 30 seconds")
  end
end
