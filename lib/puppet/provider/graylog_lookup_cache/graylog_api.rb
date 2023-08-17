require_relative '../graylog_api'

Puppet::Type.type(:graylog_lookup_cache).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do
  mk_resource_methods

  def self.instances
    results = get('system/lookup/caches')
    results['caches'].map do |data|
      cache = new(
        ensure: :present,
        name: data['name'],
        description: data['description'],
        display_name: data['title'],
        configuration: recursive_undef_to_nil(data['config'])
      )
      cache.rest_id = data['id']
      cache
    end
  end

  def flush
    data = {
      name: resource[:name],
      title: resource[:display_name],
      description: resource[:description],
      config: resource[:configuration],
    }
    data[:id] = rest_id if rest_id
    simple_flush('system/lookup/caches', data)
  end
end
