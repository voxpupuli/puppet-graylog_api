require_relative '../graylog_api'

Puppet::Type.type(:graylog_dashboard).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  def self.instances
    results = get('dashboards')
    results['dashboards'].map do |data|
      item = new(
        ensure: :present,
        name: data['title'],
        description: data['description'],
      )
      item.rest_id = data['id']
      item
    end
  end

  def flush
    simple_flush("dashboards",{
      title: resource[:name],
      description: resource[:description],
    })
  end

end