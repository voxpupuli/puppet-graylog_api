require 'puppet/property/boolean'

Puppet::Type.newtype(:graylog_auth_ldap_backend) do

  desc <<-END_OF_DOC
    @summary Configures ldap system authentication backend.

    Configures ldap system authentication backends, including the mapping mapping of users
    and Graylog Roles. Any custom graylog_role type should also be configured.

    @see graylog_role

    @example
      graylog_auth_ldap_backend{ 'company ldap':
        ensure               => present,
        enabled              => true,
        type                 => 'ldap',
        system_user_dn       => 'CN=Graylog,OU=ServiceAccounts,DC=example,DC=com',
        system_user_password => $password,
        reset_password       => false,
        server_address       => ['ldap://1.2.3.4:389/'],
        transport_security   => 'none',
        verify_certificates  => false,
        search_base_dn       => 'OU=People,DC=example,DC=com',
        search_pattern       => '(&(objectClass=person)(uid={0}))',
        name_attribute       => 'userPrincipalName',
        full_name_attribute  => 'displayName',
        default_roles        => ['Reader'],
      }
  END_OF_DOC

  ensurable

  newparam(:description) do
    desc 'Destinctive name of the authosrisation backend. Will be placed in the description field'
    isnamevar
  end

  newparam(:reset_password, boolean: true, parent: Puppet::Property::Boolean) do
    desc "Whether to reset the password with the value of system_password"
    defaultto(false)
  end

  newparam(:enabled, boolean: true, parent: Puppet::Property::Boolean) do
    desc "Whether to activate this ldap uthentication backend. Only one backend should be enabled"
  end

  newproperty(:system_user_dn) do
    desc "Username to bind to LDAP server as."
    isrequired
  end

  newproperty(:system_user_password) do
    desc "Password to bind to LDAP server with."
    sensitive true
  end

  newproperty(:server_address, array_matching: :all) do
    desc "List of LDAP servers, consisting of servername and port."
    isrequired
  end

  newproperty(:transport_security) do
    desc "Which transport security to use, can be one of 'none', 'tls', 'start_tls'"
    defaultto('tls')
    newvalues('none', 'tls', 'start_tls')
  end

  newproperty(:verify_certificates, boolean: true, parent: Puppet::Property::Boolean) do
    desc "Whether to automatically trust all certificates when using StartTLS or LDAPS."
    defaultto(false)
  end

  newproperty(:type) do
    desc "The type of the authorisation backend, can be one of 'active-directory', 'ldap'"
    isrequired
    newvalues('ldap', 'active-directory')
  end

  newproperty(:search_base_dn) do
    desc "The search base for user lookups."
    isrequired
  end

  newproperty(:search_pattern) do
    desc "The LDAP filter for user lookups."
    isrequired
  end

  newproperty(:default_roles, array_matching: :all) do
    desc "The default roles users are mapped to."
    defaultto(['Reader'])
  end

  newproperty(:name_attribute) do
    desc "The attribute for the user display name."
    isrequired
  end

  newproperty(:full_name_attribute) do
    desc "The attribute for full user name."
    isrequired
  end

  newproperty(:rest_id) do
    desc "Read-only rest_id of the ldap authentication backend resource"

    def retrieve
      current_value = nil
      current_value = @resource.rest_id if @resource.rest_id
    end

    validate do |val|
      fail "type is read-only"
    end
  end

  newproperty(:password_is_set, boolean: true, parent: Puppet::Property::Boolean) do
    desc "Read-only: flag indicating if a system user password is set or not"

    def retrieve
      current_value = false
      current_value = @resource.password_is_set if @resource.password_is_set
    end

    validate do |val|
      fail "type is read-only"
    end
  end

  autorequire('graylog_api') {'api'}
  # is there a way to exclude predefined roles ?
  autorequire('graylog_role') { self[:default_roles] }
end
