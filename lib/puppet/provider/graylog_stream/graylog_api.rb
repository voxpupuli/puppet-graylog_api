require_relative '../graylog_api'

Puppet::Type.type(:graylog_stream).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do
  @doc = 'graylog api type for graylog stream'
  mk_resource_methods

  def self.instances
    results = get('streams')
    results['streams'].map do |data|
      stream = new(
        ensure: :present,
        name: data['title'],
        description: data['description'],
        matching_type: data['matching_type'],
        enabled: !data['disabled'],
        rules: data['rules'].map { |defn| rule_from_data(defn) },
        remove_matches_from_default_stream: data['remove_matches_from_default_stream'],
        index_set: index_set_prefix_from_id(data['index_set_id'])
      )
      stream.rest_id = data['id']
      stream
    end
  end

  def self.index_set_prefix_from_id(index_set_id)
    get("system/indices/index_sets/#{index_set_id}")['prefix']
  end

  RULE_TYPES = %w[equals matches greater_than less_than field_presence contain always_match]

  def self.rule_from_data(d)
    data = recursive_undef_to_nil(d)
    {
      'field'       => data['field'],
      'description' => data['description'],
      'type'        => RULE_TYPES[data['type'] - 1],
      'inverted'    => data['inverted'],
      'value'       => data['value'],
    }
  end

  def flush
    simple_flush('streams', {
                   title: resource[:name],
                   description: resource[:description],
                   matching_type: resource[:matching_type],
                   rules: resource[:rules].map { |defn| data_from_rule(defn) },
                   remove_matches_from_default_stream: resource[:remove_matches_from_default_stream],
                   index_set_id: index_set_id_from_prefix(resource[:index_set])
                 })

    return unless exists?

    update_rules

    if resource[:enabled]
      post("streams/#{rest_id}/resume")
    else
      post("streams/#{rest_id}/pause")
    end
  end

  def set_rest_id_on_create(response)
    @rest_id = response['stream_id']
  end

  def update_rules
    rules_res = resource[:rules].map { |defn| data_from_rule(defn) }
    rules_gl = get("streams/#{rest_id}/rules")

    rules_res.each do |rule_res|
      rule_gl = rules_gl['stream_rules'].find { |rule_gl| rule_res['description'] == rule_gl['description'] }

      if rule_gl
        put("streams/#{rest_id}/rules/#{rule_gl['id']}", rule_res)
      else
        post("streams/#{rest_id}/rules", rule_res)
      end
    end
  end

  def data_from_rule(rule)
    {
      'field'       => rule['field'],
      'description' => rule['description'],
      'type'        => RULE_TYPES.index(rule['type']) + 1,
      'inverted'    => rule['inverted'],
      'value'       => rule['value'],
    }
  end

  def index_set_id_from_prefix(index_set_prefix)
    index_sets = get('system/indices/index_sets')['index_sets']
    index_set = if index_set_prefix
                  index_sets.find { |set| set['index_prefix'] == index_set_prefix }
                else
                  index_sets.find { |set| set['default'] }
                end
    index_set['id']
  end
end
