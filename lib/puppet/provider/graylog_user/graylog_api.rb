require_relative '../graylog_api'

Puppet::Type.type(:graylog_user).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  def self.instances
    results = get('users')
    items = results['users'].map do |data|
      next if data['username'] == 'admin' || data['external'] == true
      user = new(
        ensure: :present,
        name: data['username'],
        email: data['email'],
        roles: data['roles'],
        permissions: data['permissions'],
        timezone: data['timezone'],
        session_timeout_ms: data['session_timeout_ms'],
        startpage: data['startpage']
      )
      if major_version < 4
        user.full_name = data['full_name']
      else
        user.first_name = data['first_name']
        user.last_name = data['last_name']
      end

      user
    end
    items.compact
  end

  def flush
    params = {
      email: resource[:email],
      timezone: resource[:timezone],
      session_timeout_ms: resource[:session_timeout_ms],
      startpage: resource[:startpage],
      permissions: resource[:permissions],
      roles: resource[:roles]
    }

    if major_version < 4
      params = params.merge({
        full_name: resource[:full_name],
      })
    else
      params = params.merge({
        first_name: resource[:first_name],
        last_name: resource[:last_name],
      })
    end

    if @action
      simple_flush('users', params.merge({
        username: resource[:name],
        password: resource[:password]
      }))
    else
      simple_flush('users', params)
    end
  end

end
