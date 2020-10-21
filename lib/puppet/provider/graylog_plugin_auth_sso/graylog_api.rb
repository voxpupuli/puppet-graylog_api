require_relative '../graylog_api'

Puppet::Type.type(:graylog_plugin_auth_sso).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  def self.instances
      data = get('plugins/org.graylog.plugins.auth.sso/config')
      [new(
        ensure: :present,
        name: 'sso',
        trusted_proxies: data['trusted_proxies'],
        default_role: data['default_group'],
        username_header: data['username_header'],
        require_trusted_proxies: data['require_trusted_proxies'],
        auto_create_user: data['auto_create_user'],
        fullname_header: data['fullname_header'],
        email_header: data['email_header'],
        default_email_domain: data['default_email_domain'],
        sync_roles: data['sync_roles'],
        roles_header: data['roles_header']
      )]
  end


  def flush
    Puppet.info("Flushing graylog_plugin_auth_sso")
    put('plugins/org.graylog.plugins.auth.sso/config', {
      trusted_proxies: resource[:trusted_proxies],
      default_group: resource[:default_role],
      username_header: resource[:username_header],
      require_trusted_proxies: resource[:require_trusted_proxies],
      auto_create_user: resource[:auto_create_user],
      fullname_header: resource[:fullname_header],
      email_header: resource[:email_header],
      default_email_domain: resource[:default_email_domain],
      sync_roles: resource[:sync_roles],
      roles_header: resource[:roles_header]
    })
  end

end
