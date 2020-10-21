require_relative '../graylog_api'

Puppet::Type.type(:graylog_extractor).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  EXTRACTOR_TYPES = {
    copy_input: 'COPY_INPUT',
    grok: 'GROK',
    json: 'JSON', 
    regex: 'REGEX',
    regex_replace: 'REGEX_REPLACE',
    split_and_index: 'SPLIT_AND_INDEX',
    substring: 'SUBSTRING'    
  }

  mk_resource_methods
  
  def self.instances    
    results = get('system/inputs')
    input_list = results['inputs']

    extractors = input_list.reduce([]) do |acc, input_data|
      results = get("system/inputs/#{input_data['id']}/extractors")

      extractors = results['extractors'].map do |data|
        extractor = new(
          ensure: :present,
          input: input_data['title'],
          name: data['title'],
          cut_or_copy: data['cut_or_copy'],
          source_field: data['source_field'],
          target_field: data['target_field'],
          type: data['extractor_type'],
          configuration: data['extractor_config'],
          converters: data['converters'],
          condition_type: data['condition_type'],
          condition_value: data['condition_value'],
          order: data['order']
        )
        extractor.rest_id = data['id']
        extractor
      end      

      acc.concat(extractors)      
    end

    extractors
  end
  
  def flush
    input_rest_id = get_input_rest_id(resource[:input])

    simple_flush("system/inputs/#{input_rest_id}/extractors", {
      title: resource[:name],
      cut_or_copy: resource[:cut_or_copy],
      source_field: resource[:source_field],
      target_field: resource[:target_field],
      extractor_type: resource[:type],
      extractor_config: resource[:configuration],
      condition_type: resource[:condition_type],
      condition_value: resource[:condition_value],
      converters: resource[:converters],
      order: resource[:order]
    })
  end

  def set_rest_id_on_create(response)
    @rest_id = response['id']
  end

  def get_input_rest_id(name)
    results = get('system/inputs')

    id_list = results['inputs']
    .select {|data|data['title'] == name}
    .map {|data|data['id']}
    
    if id_list.length == 0
      raise "Input #{name} doesn't exist"
    end

    id_list.first
  end

end