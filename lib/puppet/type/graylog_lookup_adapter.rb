Puppet::Type.newtype(:graylog_lookup_adapter) do
  desc <<-END_OF_DOC
    @summary#{' '}
      Creates a Lookup Table Data Adapter.

    Creates a Data Adapter for use with a Lookup table. At present all
    configuration must be done manually, there are not yet any convenience
    wrappers for specific adapter types.

    @example
      graylog_lookup_adapter { 'example-adapter':
        ensure        => present,
        display_name  => "Example Data",
        description   => "A CSV file of Example Data.",
        configuration => {
          type => 'csvfile',
          path => '/etc/graylog/lookup-table.csv',
          separator => ',',
          quotechar => '"',
          key_column => 'foo',
          value_column => 'bar',
          check_interval => 60,
          case_insensitive_lookup => true,
        },
        require     => File['/etc/graylog/lookup-table.csv'],
      }

  END_OF_DOC

  ensurable

  newparam(:name) do
    desc 'The unique name of the Data Adapter. Must consist of only letters, numbers and dashes.'
    validate do |value|
      raise ArgumentError, "#{value} is not a valid name." unless value =~ %r{^[a-z0-9-]+$}
    end
  end

  newproperty(:display_name) do
    desc 'The display name (Graylog calls this "title") of the Data Adapter'
  end

  newproperty(:description) do
    desc 'A description of the Data Adapter'
  end

  newproperty(:configuration) do
    desc 'A hash of configuration for the Data Adapter. The exact configuration properties support will vary depending on the type of adapter being used.'
  end

  autorequire('graylog_api') { 'api' }
end
