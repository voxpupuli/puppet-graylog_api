Puppet::Type.newtype(:graylog_dashboard) do

  desc <<-END_OF_DOC
    @summary
      Creates an Dashboard.
      
    @see graylog_dashboard_widget
    @see graylog_dashboard_layout

    @example
      graylog_dashboard { 'Example Dashboard':
        ensure        => present,
        description   => 'An example dashboard.',
      }
  END_OF_DOC

  ensurable

  newparam(:name) do
    desc 'The name of the Dashboard.'
  end

  newproperty(:description) do
    desc 'The description of the Dashboard.'
  end

  autorequire('file') { 'graylog_api_config.yaml' }
end
