require_relative '../graylog_api'

Puppet::Type.type(:graylog_user).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  def self.instances
    results = get('users')
    items = results['users'].map do |data|
      next if data['username'] == 'admin' || data['external'] == true
      new(
        ensure: :present,
        name: data['username'],
        full_name: data['full_name'],
        email: data['email'],
        roles: data['roles'],        
        permissions: data['permissions'],
        timezone: data['timezone'],
        session_timeout_ms: data['session_timeout_ms'],
        startpage: data['startpage']        
      )
    end
    items.compact
  end

  def flush        
    user_flush({
      username: resource[:name],
      password: resource[:password],
      full_name: resource[:full_name],
      email: resource[:email],
      timezone: resource[:timezone],
      session_timeout_ms: resource[:session_timeout_ms],
      startpage: resource[:startpage],
      permissions: resource[:permissions],      
      roles: resource[:roles]
    })
  end


end