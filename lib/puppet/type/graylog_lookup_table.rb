Puppet::Type.newtype(:graylog_lookup_table) do

  ensurable

  newparam(:name) do
    desc 'The unique name of the Lookup Table. Must consist of only letters, numbers and dashes.'
    validate do |value|
      raise ArgumentError, "#{value} is not a valid name." unless value =~ /^[a-z0-9-]+$/
    end
  end

  newproperty(:display_name) do
    desc 'The display name (Graylog calls this "title") of the Lookup Table'
  end

  newproperty(:description) do
    desc 'A description of the Lookup Table'
  end

  newproperty(:default_single_value) do
    desc 'The default value for a single-value lookup'
  end

  newproperty(:default_single_value_type) do
    desc 'The default value type for a single-value lookup'
  end

  newproperty(:default_multi_value) do
    desc 'The default value for a multi-value lookup'
  end

  newproperty(:default_multi_value_type) do
    desc 'The default value type for a multi-value lookup'
  end

  newproperty(:adapter) do
    desc 'The name of the Lookup Adapter used for this Lookup Table'
  end

  newproperty(:cache) do
    desc 'The name of the Lookup Cache used for this Lookup Table'
  end

  autorequire('graylog_api') {'api'}
  autorequire('graylog_lookup_adapter') { self[:ensure] == 'absent' ? [] : self[:adapter] }
  autorequire('graylog_lookup_cache') { self[:ensure] == 'absent' ? [] : self[:cache] }
  autobefore('graylog_lookup_adapter') { self[:ensure] == 'absent' ? self[:adapter] : [] }
  autobefore('graylog_lookup_cache') { self[:ensure] == 'absent' ? self[:cache] : [] }
end
