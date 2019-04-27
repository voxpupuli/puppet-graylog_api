require_relative '../graylog_api'

Puppet::Type.type(:graylog_dashboard).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  attr_accessor :widgets

  def self.instances
    results = get('dashboards')
    results['dashboards'].map do |data|
      item = new(
        ensure: :present,
        name: data['title'],
        description: data['description'],
      )
      item.rest_id = data['id']
      item.widgets = data['widgets'].map {|w| {name: w['description'], id: w['id']} }
      item
    end
  end

  def flush
    simple_flush("dashboards",{
      title: resource[:name],
      description: resource[:description],
    })
    if @action.nil? && resource[:purge]
      catalog = resource.catalog
      widgets_in_catalog = catalog.resources.find_all do |res|
        res.class.to_s == 'Puppet::Type::Graylog_dashboard_widget' &&
        res[:name].split('!!!',2).first == resource[:name]
      end

      widgets.each do |widget|
        unless widgets_in_catalog.any? {|w| w[:name].split('!!!',2)[1] == widget[:name] }
          Puppet.notice("Purging widget '#{widget[:name]}' from Dashboard #{resource[:name]}.")
          delete("dashboards/#{rest_id}/widgets/#{widget[:id]}")
        end
      end
    end
  end

end