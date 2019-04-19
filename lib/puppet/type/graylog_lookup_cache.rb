Puppet::Type.newtype(:graylog_lookup_cache) do

  ensurable

  newparam(:name) do
    desc 'The unique name of the Lookup Cache. Must consist of only letters, numbers and dashes.'
    validate do |value|
      raise ArgumentError, "#{value} is not a valid name." unless value =~ /^[a-z0-9-]+$/
    end
  end

  newproperty(:display_name) do
    desc 'The display name (Graylog calls this "title") of the Lookup Cache'
  end

  newproperty(:description) do
    desc 'A description of the Lookup Cache'
  end

  newproperty(:configuration) do
    desc 'The configuration of the Lookup Cache'
  end

  autorequire('graylog_api') {'api'}
end
