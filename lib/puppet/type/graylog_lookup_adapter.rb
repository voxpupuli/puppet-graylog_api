Puppet::Type.newtype(:graylog_lookup_adapter) do

  ensurable

  newparam(:name) do
    desc 'The unique name of the Data Adapter. Must consist of only letters, numbers and dashes.'
    validate do |value|
      raise ArgumentError, "#{value} is not a valid name." unless value =~ /^[a-z0-9-]+$/
    end
  end

  newproperty(:display_name) do
    desc 'The display name (Graylog calls this "title") of the Data Adapter'
  end

  newproperty(:description) do
    desc 'A description of the Data Adapter'
  end

  newproperty(:configuration) do
    desc 'The configuration of the Data Adapter'
  end

  autorequire('graylog_api') {'api'}
end
