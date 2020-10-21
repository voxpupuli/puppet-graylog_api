require 'puppet/property/boolean'

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

  newproperty(:purge, boolean: true, parent: Puppet::Property::Boolean) do
    desc "Whether to remove widgets from this dashboard if they aren't declared in Puppet"
    def insync?(is)
      !provider.need_to_purge_widgets?
    end
  end

  autorequire('graylog_api') {'api'}
end
