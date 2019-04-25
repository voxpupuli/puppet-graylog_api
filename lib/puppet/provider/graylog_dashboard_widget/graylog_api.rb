require_relative '../graylog_api'

Puppet::Type.type(:graylog_dashboard_widget).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  def self.instances
    dashboards = get('dashboards')['dashboards']
    
    all_widgets = []

    dashboards.each do |dashboard|
      dashboard_name = dashboard['title']
      dashboard['widgets'].each do |data|
        widget = new(
          ensure: :present,
          dashboard: dashboard_name
          description: data['description'],
          cache_time: data['cache_time'],
          config: data['config'],
          type: data['type'],
        )
        widget.rest_id = data['id']
        all_widgets << widget
      end
    end
    all_widgets
  end

  def flush
    dashboards = get("dashboards")['dashboards']
    dashboard = dashboards.find {|db| db['title'] == resouce[:dashboard] }
    dashboard_id = dashboard['id']

    simple_flush("dashboards/#{dashboard_id}/widgets",{
      description: resource[:description],
      cache_time: resouce[:cache_time],
      config: resource[:config],
      type: resource[:type],
    })
  end

end