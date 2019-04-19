require_relative '../graylog_api'

Puppet::Type.type(:graylog_lookup_table).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  def self.instances
    tables = get('system/lookup/tables')['lookup_tables']
    adapters = get('system/lookup/adapters')['data_adapters']
    caches = get('system/lookup/caches')['caches']

    tables.map do |data|
      cache_name = caches.find {|cache| cache['id'] == data['cache_id'] }['name']
      adapter_name = adapters.find {|adapter| adapter['id'] == data['data_adapter_id'] }['name']
      table = new(
        ensure: :present,
        name: data['name'],
        description: data['description'],
        display_name: data['title'],
        adapter: adapter_name,
        cache: cache_name,
        default_single_value: data['default_single_value'],
        default_single_value_type: data['default_single_value_type'],
        default_multi_value: data['default_multi_value'],
        default_multi_value_type: data['default_multi_value'],
      )
      table.rest_id = data['id']
      table
    end
  end

  def flush
    adapter_id = get("system/lookup/adapters/#{resource[:adapter]}")['id']
    cache_id   = get("system/lookup/caches/#{resource[:cache]}")['id']
    simple_flush("system/lookup/tables",{
      name: resource[:name],
      title: resource[:display_name],
      description: resource[:description],
      data_adapter_id: adapter_id,
      cache_id: cache_id,
      default_single_value: resource[:default_single_value],
      default_single_value_type: resource[:default_single_value_type],
      default_multi_value: resource[:default_multi_value],
      default_multi_value_type: resource[:default_multi_value_type],
    })
  end

end