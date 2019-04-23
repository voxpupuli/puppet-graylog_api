require 'puppet/property/boolean'

Puppet::Type.newtype(:graylog_ldap_settings) do

  desc <<-END_OF_DOC
    Configures LDAP authentication, include the mapping between LDAP Groups and
    Graylog Roles. Make sure you also configure the Graylog Roles themselves
    using the graylog_role type.

    Example:

      graylog_ldap_settings { 'ldap':
        enabled                   => true,
        system_username           => 'CN=Graylog,OU=ServiceAccounts,DC=example,DC=com',
        system_password           => $password,
        ldap_uri                  => "ldap://1.2.3.4:389/",
        use_start_tls             => true,
        trust_all_certificates    => false,
        active_directory          => false,
        search_base               => 'OU=People,DC=example,DC=com',
        search_pattern            => '(&(objectClass=person)(uid={0}))',
        display_name_attribute    => 'displayName',
        default_group             => 'Reader',
        group_search_base         => 'OU=Groups,DC=example,DC=com',
        group_id_attribute        => 'cn',
        additional_default_groups => [],
        group_search_pattern      => '(objectClass=group)',
        group_mapping             => {
          'GraylogAdmins' => 'Admin',
          'Developers'    => 'PowerUser',
        },
      }
  END_OF_DOC

  newparam(:name) do
    desc 'Must be "ldap", only one instance of the graylog_ldap_settings type is allowed.'
    newvalues('ldap')
  end

  newproperty(:enabled, boolean: true, parent: Puppet::Property::Boolean) do
    desc "Whether to enable LDAP authentication."
  end

  newproperty(:system_username) do
    desc "Username to bind to LDAP server as."
  end

  newproperty(:system_password) do
    desc "Password to bind to LDAP server with."
  end

  newproperty(:ldap_uri) do
    desc "URI of LDAP server, including protocol and port."
  end

  newproperty(:use_start_tls) do
    desc "Whether to use StartTLS"
  end

  newproperty(:trust_all_certificates, boolean: true, parent: Puppet::Property::Boolean) do
    desc "Whether to automatically trust all certificates when using StartTLS or LDAPS."
  end

  newproperty(:active_directory, boolean: true, parent: Puppet::Property::Boolean) do
    desc "Whether the LDAP server is an active directory server."
  end

  newproperty(:search_base) do
    desc "The search base for user lookups."
  end

  newproperty(:search_pattern) do
    desc "The LDAP filter for user lookups."
  end

  newproperty(:default_group) do
    desc "The default group users are mapped to."
  end

  newproperty(:group_mapping) do
    desc "A hash mapping LDAP groups to Graylog roles."
  end

  newproperty(:group_search_base) do
    desc "The search base for group lookups."
  end

  newproperty(:group_id_attribute) do
    desc "The attribute by which LDAP groups are identified."
  end

  newproperty(:additional_default_groups, array_matching: :all) do
    desc "Additional groups to apply by default to all users."
  end

  newproperty(:group_search_pattern) do
    desc "The LDAP filter for group lookups."
  end

  newproperty(:display_name_attribute) do
    desc "The attribute for user display names."
  end

  autorequire('graylog_api') {'api'}
  autorequire('graylog_role') { self[:group_mapping].values + [self[:default_group]] }
end
