require_relative '../graylog_api'

Puppet::Type.type(:graylog_dashboard_widget).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  def self.instances
    dashboards = get('dashboards')['dashboards']
    
    all_widgets = []

    dashboards.each do |dashboard|
      dashboard_name = dashboard['title']
      dashboard['widgets'].each do |data|
        id = data['id']
        position = dashboard['positions'][id]
        widget = new(
          ensure: :present,
          name: data['description'],
          dashboard: dashboard_name,
          cache_time: data['cache_time'],
          config: data['config'],
          type: data['type'],
          position: position,
        )
        widget.rest_id = id
        all_widgets << widget
      end
    end
    all_widgets
  end

  def set_rest_id_on_create(response)
    @rest_id = response['widget_id']
  end

  def flush
    dashboards = get("dashboards")['dashboards']
    dashboard = dashboards.find {|db| db['title'] == resource[:dashboard] }
    dashboard_id = dashboard['id']

    simple_flush("dashboards/#{dashboard_id}/widgets",{
      description: resource[:name],
      cache_time: resource[:cache_time],
      config: resource[:config],
      type: resource[:type],
    })
    if new_position = resource[:position].dup
      old_position = dashboard['positions'][self.rest_id]
      if new_position != old_position
        new_position['id'] = self.rest_id
        put("dashboards/#{dashboard_id}/positions",{
          positions: [ new_position ],
        })
      end
    end
  end
end