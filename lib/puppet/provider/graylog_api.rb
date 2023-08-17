require 'httparty' if Puppet.features.httparty?
require 'json' if Puppet.features.json?
require 'retries' if Puppet.features.retries?

class Puppet::Provider::GraylogAPI < Puppet::Provider
  confine feature: :json
  confine feature: :httparty
  confine feature: :retries

  class << self
    attr_writer :api_password, :api_port, :api_username, :api_tls, :api_server,
                :ssl_ca_file, :verify_tls

    def api_password
      @api_password || ENV.fetch('GRAYLOG_API_PASSWORD', nil)
    end

    def api_port
      @api_port || ENV['GRAYLOG_API_PORT'] || 9000
    end

    def api_username
      @api_username || ENV['GRAYLOG_API_USERNAME'] || 'admin'
    end

    def api_tls
      @api_tls || false
    end

    def api_server
      @api_server || 'localhost'
    end

    def ssl_ca_file
      @ssl_ca_file || '/etc/pki/tls/certs/ca-bundle.crt'
    end

    def verify_tls
      @verify_tls || false
    end

    def version
      @version ||= get('system')['version']
    end

    def major_version
      @major_version ||= version.split('.').first.to_i
    end

    def tls_opts
      api_tls ? { verify_tls: verify_tls, ssl_ca_file: ssl_ca_file } : {}
    end

    def request(method, path, params = {})
      api_password = Puppet::Provider::GraylogAPI.api_password
      api_port = Puppet::Provider::GraylogAPI.api_port
      api_username = Puppet::Provider::GraylogAPI.api_username
      api_tls = Puppet::Provider::GraylogAPI.api_tls
      api_server = Puppet::Provider::GraylogAPI.api_server

      raise "No Graylog_api['api'] resource defined!" unless api_password && api_port # It would be nicer to do this in the Type, but I don't see how without writing it over and over again for each type.

      case method
      when :get, :delete
        headers = {
          'Accept' => 'application/json',
          'X-Requested-By' => 'puppet',
        }
        query = params
        body = nil
      when :post, :put
        headers = {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'X-Requested-By' => 'puppet',
        }
        body = params.to_json
        query = nil
      end
      begin
        scheme = api_tls ? 'https' : 'http'

        Puppet.debug { "#{method.upcase} request for #{scheme}://#{api_server}:#{api_port}/api/#{path} with params #{params.inspect}" }
        result = HTTParty.send(
          method,
          "#{scheme}://#{api_server}:#{api_port}/api/#{path}",
          basic_auth: {
            username: api_username,
            password: api_password,
          },
          headers: headers,
          query: query,
          body: body,
          **tls_opts
        )

        if result.body
          if result.body.include? '"type":"ApiError"'
            Puppet.send_log(:err, "Got error response #{result.body}")
            raise
          end

          Puppet.debug("Got result #{result.body}")
        end
      rescue HTTParty::ResponseError => e
        Puppet.send_log(:err, "Got error response #{e.response}")
        raise e
      end
      recursive_nil_to_undef(JSON.parse(result.body)) unless result.nil?
    end

    # Under Puppet Apply, undef in puppet-lang becomes :undef instead of nil
    def recursive_nil_to_undef(data)
      return data unless Puppet.settings[:name] == 'apply'

      case data
      when nil
        :undef
      when Array
        data.map { |item| recursive_nil_to_undef(item) }
      when Hash
        data.transform_values { |value| recursive_nil_to_undef(value) }
      else
        data
      end
    end

    # This intentionally only goes one layer deep
    def symbolize(hsh)
      hsh.map { |k, v| [k.to_sym, v] }.to_h
    end

    def get(path, params = {})
      request(:get, path, params)
    end

    def put(path, params = {})
      request(:put, path, params)
    end

    def post(path, params = {})
      request(:post, path, params)
    end

    def delete(path, params = {})
      request(:delete, path, params)
    end

    def prefetch(resources)
      items = instances
      resources.each_pair do |name, resource|
        if provider = items.find { |item| item.name == name.to_s }
          resource.provider = provider
        end
      end
    end
  end

  attr_writer :rest_id

  attr_reader :initial_params

  def initialize(parameters)
    @initial_params = parameters.to_hash.dup
    super
  end

  def rest_id
    @rest_id || resource[:name]
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @action = :create
  end

  def destroy
    @action = :destroy
  end

  # Under Puppet Apply, undef in puppet-lang becomes :undef instead of nil
  def self.recursive_undef_to_nil(data)
    return data unless Puppet.settings[:name] == 'apply'

    case data
    when :undef
      nil
    when Array
      data.map { |item| recursive_undef_to_nil(item) }
    when Hash
      data.transform_values { |value| recursive_undef_to_nil(value) }
    else
      data
    end
  end

  %i[request get put post delete symbolize version major_version recursive_undef_to_nil].each do |m|
    method = self.method(m)
    define_method(m) { |*args| method.call(*args) }
  end

  def node_id
    get('/system')['node_id']
  end

  def simple_flush(path, params)
    params = recursive_undef_to_nil(params)
    case @action
    when :destroy
      delete("#{path}/#{rest_id}")
    when :create
      response = post("#{path}", params)
      set_rest_id_on_create(response) if respond_to?(:set_rest_id_on_create)
    else
      put("#{path}/#{rest_id}", params)
    end
  end
end
