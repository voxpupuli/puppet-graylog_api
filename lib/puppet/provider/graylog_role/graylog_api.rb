require_relative '../graylog_api'

Puppet::Type.type(:graylog_role).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  attr_writer :permission_cache

  def self.instances
    cache = []
    results = get('roles')
    items = results['roles'].map do |data|
      next if ['Admin', 'Reader'].include?(data['name'])

      permissions = permissions_to_names(data['permissions'], cache)
      role = new(
        ensure: :present,
        name: data['name'],
        description: data['description'],
        permissions: permissions
      )

      role.rest_id = data['id']
      role
    end
    items.compact
  end

  def flush
    cache = []
    permissions = self.class.permissions_to_ids(resource[:permissions], cache)

    Puppet.send_log(:info, "FLUSH: PUPPET: #{resource[:name]}: #{resource[:permissions]}")
    Puppet.send_log(:info, "FLUSH: TO GRAYLOG #{resource[:name]}: #{permissions}")

    simple_flush("roles",{
      name: resource[:name],
      description: resource[:description],
      permissions: permissions,
      read_only: false,
    })
  end

  def set_rest_id_on_create(response)
    @rest_id = response['id']
  end

  def self.get_ref(permission)
    permission[/^streams:\w+:(.+)/, 1]
  end

  def self.read_cache(ref, cache)
    cache.detect do |data|
      data[:id] == ref || data[:name] == ref
    end
  end

  def self.write_cache(ref, cache)
    streams = get('streams')
    stream = streams['streams'].detect do |stream|
      stream['id'] == ref || stream['title'] == ref
    end

    if !stream
      Puppet.send_log(:err, "Stream reference not found #{ref}")
      raise
    end

    data = { :id => stream['id'], :name => stream['title'] }
    cache.push(data)
    data
  end

  def self.map_permissions(list, cache, key)
    list.map do |permission|
      if permission.match?(/^streams:\w+:/)
        ref = get_ref(permission)
        stream = read_cache(ref, cache)

        if !stream
          stream = write_cache(ref, cache)
        end


        permission.sub(/^(streams:\w+):(.+)/, "\\1:#{stream[key]}")
      else
        permission
      end
    end
  end

  def self.permissions_to_names(list, cache)
    map_permissions(list, cache, :name)
  end

  def self.permissions_to_ids(list, cache)
    map_permissions(list, cache, :id)
  end

end