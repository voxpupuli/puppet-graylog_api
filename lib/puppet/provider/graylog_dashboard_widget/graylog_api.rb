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
        widget = new(
          ensure: :present,
          name: "#{dashboard_name}!!!#{data['description']}",
          cache_time: data['cache_time'],
          config: data['config'],
          type: data['type']
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
    dashboards = get('dashboards')['dashboards']
    dashboard_name, widget_name = resource[:name].split('!!!', 2)
    dashboard = dashboards.find { |db| db['title'] == dashboard_name }
    dashboard_id = dashboard['id']

    simple_flush("dashboards/#{dashboard_id}/widgets", {
                   description: widget_name,
                   cache_time: resource[:cache_time],
                   config: resource[:config],
                   type: resource[:type],
                 })
  end
end
