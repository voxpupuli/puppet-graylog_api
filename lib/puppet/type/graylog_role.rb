Puppet::Type.newtype(:graylog_role) do
  desc <<-END_OF_DOC
    @summary
      Creates a user role.

    A user role definition. Note that the Admin and Reader roles are built-in
    and cannot be modified.

    @example
      graylog_role { 'example':
        description => 'An example user role',
        permissions => [
          'dashboards:create',
          'dashboards:edit',
          'dashboards:read',
          'savedsearches:read',
          'savedsearches:edit',
          'savedsearches:create',
          'searches:relative',
          'searches:keyword',
          'searches:absolute',
          'streams:read',
        ],
      }
  END_OF_DOC

  ensurable

  newparam(:name) do
    desc 'The name of the role'
    validate do |value|
      raise 'The Admin role is built-in and may not be changed' if value == 'Admin'
      raise 'The Reader role is built-in and may not be changed' if value == 'Reader'
    end
  end

  newproperty(:description) do
    desc 'A description of the role.'
  end

  newproperty(:permissions, array_matching: :all) do
    desc 'Permissions this role provides, see the /system/permissions API endpoint for list of valid permissions.'
    def insync?(is)
      is.sort == should.sort
    end
  end

  autorequire('graylog_api') { 'api' }
end
