require_relative '../graylog_api'

Puppet::Type.type(:graylog_dashboard).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do
  @doc = 'graylog api type for graylog dashboard'
  mk_resource_methods

  attr_accessor :widgets

  def self.instances
    results = get('dashboards')
    results['dashboards'].map do |data|
      item = new(
        ensure: :present,
        name: data['title'],
        description: data['description']
      )
      item.rest_id = data['id']
      item.widgets = data['widgets'].map { |w| { name: w['description'], id: w['id'] } }
      item
    end
  end

  def need_to_purge_widgets?
    Puppet.debug("Purge: #{resource[:purge]}")
    Puppet.debug("Widgets to Purge: #{widgets_to_purge}")
    resource[:purge] && widgets_to_purge.any?
  end

  def widgets_in_catalog
    @widgets_in_catalog ||= resource.catalog.resources.find_all do |res|
      res.instance_of?(Puppet::Type::Graylog_dashboard_widget) &&
        res[:name].split('!!!', 2).first == resource[:name]
    end
  end

  def widgets_to_purge
    @widgets_to_purge ||= widgets.select do |widget|
      widgets_in_catalog.none? { |w| w[:name].split('!!!', 2)[1] == widget[:name] }
    end
  end

  def flush
    simple_flush('dashboards', {
                   title: resource[:name],
                   description: resource[:description],
                 })
    Puppet.debug("@action = '#{@action}'")
    return unless @action.nil? && resource[:purge]

    widgets_to_purge.each do |widget|
      Puppet.notice("Purging widget '#{widget[:name]}' from Dashboard #{resource[:name]}.")
      delete("dashboards/#{rest_id}/widgets/#{widget[:id]}")
    end
  end
end
