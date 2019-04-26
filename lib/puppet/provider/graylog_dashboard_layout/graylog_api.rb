require_relative '../graylog_api'

Puppet::Type.type(:graylog_dashboard_layout).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  def self.instances
    dashboards = get('dashboards')['dashboards']
    
    dashboards.map do |dashboard|
      dashboard_name = dashboard['title']
      widgets_data = dashboard['widgets']
      positions_data = dashboard['positions']

      positions = {}

      position_data.each_pair do |widget_id, position_data|
        widget_data = widgets_data.find {|widget| widget['id'] == widget_id }
        widget_name = widget_data['description']
        positions[widget_name] = {
          x: position['col'],
          y: position['row'],
          w: position['width'],
          h: position['height'],
        }
      end

      new(
        name: dashboard_name,
        positions: positions,
      )
    end
  end

  def flush
    dashboards = get("dashboards")['dashboards']
    dashboard = dashboards.find {|db| db['title'] == resource[:dashboard] }
    dashboard_id = dashboard['id']

    position_data = {}
    resource[:positions].each_pair do |widget_name,position|
      widget_data = dashboard['widgets'].find {|widget| widget['description'] == widget_name }
      widget_id = widget_data['id']

      position_data[widget_id] = {
        col: position['x'],
        row: position['y'],
        width: position['w'],
        height: position['h'],
      }
    end

    put("dashboards/#{dashboard_id}/positions",{positions: position_data})
  end
end