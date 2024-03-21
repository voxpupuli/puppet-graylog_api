require_relative '../graylog_api'

Puppet::Type.type(:graylog_ldap_settings).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do
  @doc = 'graylog api type for graylog ldap settings'
  mk_resource_methods

  def self.instances
    result = get('system/ldap/settings')
    [new(name: 'ldap', **symbolize(result))]
  end

  def flush
    Puppet.info('Flushing graylog_ldap_settings')
    data = @property_hash.reject { |k, _v| k == :name }
    put('system/ldap/settings', recursive_undef_to_nil(data))
  end
end
