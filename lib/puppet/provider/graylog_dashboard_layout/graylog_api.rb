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

      positions_data.each_pair do |widget_id, position_data|
        widget_data = widgets_data.find {|widget| widget['id'] == widget_id }
        Puppet.error("Could not find widget #{widget_id} on dashboard #{dashboard_name}") unless widget_data
        widget_name = widget_data['description']
        positions[widget_name] = {
          'x' => position_data['col'],
          'y' => position_data['row'],
          'w' => position_data['width'],
          'h' => position_data['height'],
        }
      end

      Puppet.debug("Final Layout for '#{dashboard_name}': #{positions.inspect}")

      new(
        name: dashboard_name,
        positions: positions,
      )
    end
  end

  def flush
    dashboards = get("dashboards")['dashboards']
    dashboard = dashboards.find {|db| db['title'] == resource[:name] }
    dashboard_id = dashboard['id']

    positions_data = resource[:positions].map do |widget_name,position|
      widget_data = dashboard['widgets'].find {|widget| widget['description'] == widget_name }
      {
        id: widget_data['id'],
        col: position['x'],
        row: position['y'],
        width: position['w'],
        height: position['h'],
      }
    end

    put("dashboards/#{dashboard_id}/positions",{positions: positions_data})
  end
end