require_relative '../graylog_api'

Puppet::Type.type(:graylog_lookup_adapter).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do
  @doc = 'graylog api type for graylog lookup adapter'
  mk_resource_methods

  def self.instances
    results = get('system/lookup/adapters')
    results['data_adapters'].map do |data|
      adapter = new(
        ensure: :present,
        name: data['name'],
        description: data['description'],
        display_name: data['title'],
        configuration: recursive_undef_to_nil(data['config'])
      )
      adapter.rest_id = data['id']
      adapter
    end
  end

  def flush
    simple_flush('system/lookup/adapters', {
                   name: resource[:name],
                   title: resource[:display_name],
                   description: resource[:description],
                   config: resource[:configuration],
                 })
  end
end
