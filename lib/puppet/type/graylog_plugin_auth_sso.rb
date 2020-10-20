require 'puppet/property/boolean'

Puppet::Type.newtype(:graylog_plugin_auth_sso) do

  desc <<-END_OF_DOC
    @summary
      SSO authentication plugin configuration

    SSO authentication pluging configuration definition.

    @example
      graylog_auth_sso_plugin_config { 'org.graylog.plugins.foo/config':
        trusted_proxies: '127.0.0.1/32',
        username_header: 'REMOTE_USER'
        require_trusted_proxies: true
        auto_create_user: true
        fullname_header: 'displayName'
        email_header: 'mail'
        default_email_domain: 'foo.bar'
        sync_roles: true
        roles_header: 'fooGroup'
      }
  END_OF_DOC

  ensurable

  newparam(:name) do
    desc 'Resource name'
  end

  newproperty(:trusted_proxies) do
    desc 'Enable this to require the request containing the SSO header as directly coming from a trusted proxy. This is highly recommended to avoid header injection.'
    isrequired
  end

  newproperty(:username_header) do
    desc 'HTTP header containing the implicitly trusted name of the Graylog user'
    isrequired
  end

  newproperty(:fullname_header) do
    desc 'HTTP header containing the full name of user to create (defaults to the user name).'
    isrequired
  end

  newproperty(:email_header) do
    desc 'HTTP header containing the email address of user to create'
    isrequired
  end

  newproperty(:default_email_domain) do
    desc 'The default domain to use if there is no email header configured'
    isrequired
  end

  newproperty(:default_role) do
    desc 'The default Graylog role determines whether a user created can access the entire system, or has limited access.'
    defaultto('Reader')
  end

  newproperty(:require_trusted_proxies, boolean: true, parent: Puppet::Property::Boolean) do
    desc 'Enable this to require the request containing the SSO header as directly coming from a trusted proxy. This is highly recommended to avoid header injection.
    The current subnet setting is: 127.0.0.1/32, 0:0:0:0:0:0:0:1/128. You can configure the setting in the Graylog server configuration file.'
    defaultto(true)
  end

  newproperty(:auto_create_user, boolean: true, parent: Puppet::Property::Boolean) do
    desc 'Enable this if Graylog should automatically create a user account for externally authenticated users. If disabled, an administrator needs to manually create a user account.'
    defaultto(false)
  end

  newproperty(:sync_roles, boolean: true, parent: Puppet::Property::Boolean) do
    desc 'Enable this if Graylog should automatically synchronize the roles of the user, with that specified in the HTTP header. Only existing roles in Graylog will be added to the user.'
    defaultto(false)
  end

  newproperty(:roles_header) do
    desc 'Prefix of the HTTP header, can contain a comma-separated list of roles in one header, otherwise all headers with that prefix will be recognized.'
    defaultto('')
  end

  autorequire('graylog_api') {'api'}
end