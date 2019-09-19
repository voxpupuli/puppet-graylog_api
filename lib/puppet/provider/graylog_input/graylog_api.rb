require_relative '../graylog_api'
require 'pry'

Puppet::Type.type(:graylog_input).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  INPUT_TYPES = {
    gelf_tcp: 'org.graylog2.inputs.gelf.tcp.GELFTCPInput',
    gelf_udp: 'org.graylog2.inputs.gelf.udp.GELFUDPInput',
    gelf_http: 'org.graylog2.inputs.gelf.http.GELFHttpInput', 
    gelf_amqp: 'org.graylog2.inputs.gelf.amqp.GELFAMQPInput', 
    gelf_kafka: 'org.graylog2.inputs.gelf.kafka.GELFKafkaInput', 
    syslog_tcp: 'org.graylog2.inputs.syslog.tcp.SyslogTCPInput', 
    syslog_udp: 'org.graylog2.inputs.syslog.udp.SyslogUDPInput', 
    syslog_amqp: 'org.graylog2.inputs.syslog.amqp.SyslogAMQPInput', 
    syslog_kafka: 'org.graylog2.inputs.syslog.kafka.SyslogKafkaInput',
    raw_tcp: 'org.graylog2.inputs.raw.tcp.RawTCPInput', 
    raw_udp: 'org.graylog2.inputs.raw.udp.RawUDPInput', 
    raw_amqp: 'org.graylog2.inputs.raw.amqp.RawAMQPInput',
    raw_kafka: 'org.graylog2.inputs.raw.kafka.RawKafkaInput', 
    cef_tcp: 'org.graylog.plugins.cef.input.CEFTCPInput', 
    cef_udp: 'org.graylog.plugins.cef.input.CEFUDPInput', 
    cef_amqp: 'org.graylog.plugins.cef.input.CEFAmqpInput', 
    cef_kafka: 'org.graylog.plugins.cef.input.CEFKafkaInput',  
    aws_cloudtrail: 'org.graylog.aws.inputs.cloudtrail.CloudTrailInput', 
    aws_cloudwatch: 'org.graylog.aws.inputs.cloudwatch.CloudWatchLogsInput', 
    aws_flow_logs: 'org.graylog.aws.inputs.flowlogs.FlowLogsInput',
    netflow_udp: 'org.graylog.plugins.netflow.inputs.NetFlowUdpInput',
    beats: 'org.graylog.plugins.beats.BeatsInput',
    beats2: 'org.graylog.plugins.beats.Beats2Input',
    json_path: 'org.graylog2.inputs.misc.jsonpath.JsonPathInput', 
    fake: 'org.graylog2.inputs.random.FakeHttpMessageInput',
  }

  mk_resource_methods

  def self.instances
    results = get('system/inputs')
    results['inputs'].map do |data|
      input = new(
        ensure: :present,
        name: data['title'],
        type: data['type'],
        scope: (data['global'] ? 'global' : 'local'),
        configuration: recursive_undef_to_nil(data['attributes']),
        static_fields: data['static_fields'],
      )
      input.rest_id = data['id']
      input
    end
  end

  def set_rest_id_on_create(response)
    @rest_id = response['id']
  end

  def flush
    simple_flush("system/inputs",{
      title: resource[:name],
      type: resource[:type],
      global: global?,
      configuration: resource[:configuration],
      node: node,
    })
    update_static_fields if resource[:static_fields].kind_of?(Hash) && @action != :delete
  end

  def update_static_fields
    initial = initial_params[:static_fields]
    fields_to_add, fields_to_remove = if initial
      [
        resource[:static_fields].select {|k,v| initial[k] != v },
        initial.keys - resource[:static_fields].keys
      ]
    else
      [resource[:static_fields],[]]
    end

    fields_to_add.each_pair do |key,value|
      post("system/inputs/#{rest_id}/staticfields", {key: key, value: value})
    end

    fields_to_remove.each do |key|
      delete("system/inputs/#{rest_id}/staticfields/#{key}")
    end
  end

  def global?
    resource[:scope] == :global
  end

  def node
    global? ? nil : node_id
  end

end