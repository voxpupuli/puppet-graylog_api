require_relative '../graylog_api'

Puppet::Type.type(:graylog_pipeline_rule).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  def self.api_prefix
    major_version == 2 ? 'plugins/org.graylog.plugins.pipelineprocessor/' : ''
  end
  def api_prefix
    self.class.api_prefix
  end

  def self.instances
    results = get("#{api_prefix}system/pipelines/rule")
    results.map do |data|
      item = new(
        ensure: :present,
        name: data['title'],
        description: data['description'],
        source: data['source'],
      )
      item.rest_id = data['id']
      item
    end
  end

  def flush
    simple_flush("#{api_prefix}system/pipelines/rule",{
      title: resource[:name],
      description: resource[:description],
      source: resource[:source],
    })
  end

end