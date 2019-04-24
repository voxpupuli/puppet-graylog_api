Puppet::Type.newtype(:graylog_lookup_cache) do

  desc <<-END_OF_DOC
    @summary
      Creates a Lookup Table Cache.

    Creates a Cache for use with a Lookup Table. By default Graylog only
    supports two cache types, a noop cache called "none" and an in-memory
    cache called "guava_cache".

    @example
      graylog_lookup_cache { 'example-cache':
        ensure        => present,
        display_name  => 'Example Data',
        description   => 'A cache of example data.',
        configuration => {
          type                     => 'guava_cache',
          max_size                 => 1000,
          expire_after_access      => 60,
          expire_after_access_unit => 'SECONDS',
          expire_after_write       => 0,
          expire_after_write_unit  => undef,
        },
      }
  END_OF_DOC
  
  ensurable

  newparam(:name) do
    desc 'The unique name of the Lookup Cache. Must consist of only letters, numbers and dashes.'
    validate do |value|
      raise ArgumentError, "#{value} is not a valid name." unless value =~ /^[a-z0-9-]+$/
    end
  end

  newproperty(:display_name) do
    desc 'The display name (Graylog calls this "title") of the Lookup Cache.'
  end

  newproperty(:description) do
    desc 'A description of the Lookup Cache.'
  end

  newproperty(:configuration) do
    desc 'A hash of configuration for the Lookup Cache. The exact properties will vary depending on the type of cache being managed.'
  end

  autorequire('graylog_api') {'api'}
end
