require_relative '../graylog_api'

Puppet::Type.type(:graylog_pipeline).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do
  @doc = 'graylog api type for graylog pipeline'
  mk_resource_methods

  def self.api_prefix
    major_version == 2 ? 'plugins/org.graylog.plugins.pipelineprocessor/' : ''
  end

  def api_prefix
    self.class.api_prefix
  end

  def self.instances
    pipelines = get("#{api_prefix}system/pipelines/pipeline")
    connections = get("#{api_prefix}system/pipelines/connections")
    pipelines.map do |data|
      connected_streams = connections.select { |conn| conn['pipeline_ids'].include?(data['id']) }.map do |conn|
        stream_id = conn['stream_id']
        stream_data = get("streams/#{stream_id}")
        stream_data['title']
      end
      item = new(
        ensure: :present,
        name: data['title'],
        description: data['description'],
        source: data['source'],
        connected_streams: connected_streams
      )
      item.rest_id = data['id']
      item
    end
  end

  def set_rest_id_on_create(response)
    @rest_id = response['id']
  end

  def flush
    simple_flush("#{api_prefix}system/pipelines/pipeline", {
                   title: resource[:name],
                   description: resource[:description],
                   source: resource[:source],
                 })
    all_streams = get('streams')['streams']
    connected_stream_ids = resource[:connected_streams].map do |stream_name|
      stream = all_streams.find { |stream| stream['title'] == stream_name }
      raise "Could not find stream named #{stream_name}" unless stream

      stream['id']
    end
    post("#{api_prefix}system/pipelines/connections/to_pipeline", {
           pipeline_id: rest_id,
           stream_ids: connected_stream_ids,
         })
  end
end
