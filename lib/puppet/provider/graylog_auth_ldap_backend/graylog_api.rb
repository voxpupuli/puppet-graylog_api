require_relative '../graylog_api'

Puppet::Type.type(:graylog_auth_ldap_backend).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  attr_writer :role_cache

  attr_accessor :active_backend_id
  attr_accessor :roles_map

  def self.instances
    if major_version < 4
      fail('graylog_oauth_ldap_bckend type is not supported in Graylog versions older then 4.x')
    end

    get_active_backend_id
    result = get('system/authentication/services/backends')

    items = result['backends'].map do |data|
      # skip non ldap backends
      next unless ['active-directory', 'ldap'].include?(data['config']['type'])
      roles = roles_to_names(data['default_roles'])
      su_password = @resource[:system_user_password] if (data['config']['system_user_password']['is_set'] and !@resource[:reset_password])

      new(
        name:                 data['description'],
        description:          data['description'],
        ensure:               :present,
        enabled:              data['id'] == @active_backend_id,
        type:                 data['config']['type'],
        system_user_dn:       data['config']['system_user_dn'],
        server_address:       data['config']['servers'].map { |srv| "#{srv['host']}:#{srv['port']}" },
        transport_security:   data['config']['transport_security'],
        verify_certificates:  data['config']['verify_certificates'],
        search_base_dn:       data['config']['user_search_base'],
        search_pattern:       data['config']['user_search_pattern'],
        name_attribute:       data['config']['user_name_attribute'],
        full_name_attribute:  data['config']['user_full_name_attribute'],
        default_roles:        roles,
        password_is_set:      data['config']['system_user_password']['is_set'],
        system_user_password: su_password,
        rest_id:              data['id'],
      )
    end
    items.compact
  end

  def flush
    Puppet.debug("THE RESOURCE contains #{resource.methods}")
    active_backend_id = self.class.get_active_backend_id
    roles = self.class.roles_to_ids(resource[:default_roles])
    Puppet.send_log(:info, "FLUSH: PUPPET: #{resource[:description]}: #{resource[:default_roles]}")
    Puppet.send_log(:info, "FLUSH: TO GRAYLOG: #{resource[:description]}: #{roles}")
    data = {
      default_roles: roles,
      description: resource[:description],
      title: resource[:type] == 'ldap' ? 'LDAP' : 'Active Directory',
      config: {
        type: resource[:type],
        servers: resource[:server_address].map { |uri|
          a=uri.split(':')
          {
            host: a[0],
            port: a[1],
          }
        },
        transport_security: resource[:transport_security],
        verify_certificates: resource[:verify_certificates],
        system_user_dn: resource[:system_user_dn],
        user_search_base: resource[:search_base_dn],
        user_search_pattern: resource[:search_pattern],
        user_full_name_attribute: resource[:full_name_attribute],
        user_name_attribute: resource[:name_attribute],
      }
    }

    #Puppet.debug("Reset password?: #{@resource[:reset_password]}")
    #if resource[:reset_password] or not password_is_set
    #  Puppet.debug("THE PASSWORD NEEDS TO BE SET (action =  #{@action} - forced_reset: #{@resource[:reset_password]} -  pw set: #{password_is_set}")
    #  data[:config] = data[:config].merge({
    #    system_user_password: resource[:system_user_password],
    #  })
    #end

    if @action == :destroy and rest_id.eql? active_backend_id
      # we need to deactivate this backend before removal.  Otherwise we get the following error:
      # {"type":"ApiError","message":"Authentication service backend <638a2eeca065b64a660fb724> is still in use"}
      post('system/authentication/services/configuration', {active_backend: nil})
    end
    simple_flush('system/authentication/services/backends', data)

    if @action != :create
      params = nil
      if resource[:enabled] and @action != :destroy
        # Only one active backend is allowed.  When multiple resources have enabled => true
        # the last one in the catlogue will be the active one.
        # When an activa backend is removed, this will also deactivate that backend.  This could lead
        # to no active backends.
        # When enabled => false, we set the active backend to 'null', but only if it is the active backend
        # We cannot ganrantuee that we have an active backend, by the nature of the api calls.
        if rest_id != active_backend_id
          params = {
            active_backend: rest_id
          }
          Puppet.send_log(:info, "FLUSH: GRAYLOG: Activating ldap backend with id: #{rest_id}")
        end
      else
        if rest_id == active_backend_id
          params = {
            active_backend: nil
          }
          Puppet.send_log(:info, "FLUSH: GRAYLOG: Deactivating ldap backend with id: #{rest_id}")
        end
      end

      if params
        post('system/authentication/services/configuration', params)
      end
    end
  end

  def self.get_active_backend_id
    @active_backend_id = get('system/authentication/services/configuration')['configuration']['active_backend']
  end

  def set_rest_id_on_create(response)
    @rest_id = response['backend']['id']
  end

  def self.map_roles(list, key)
    if !@map_roles
      @map_roles = {}
      get('authz/roles')['roles'].each do |role|
        @map_roles[role['id']] = role['name']
      end
    end

    result = []
    list.each do |val|
      if key == :name
        result << @map_roles[val]
      else
        result << @map_roles.key(val)
      end
    end

    result
  end

  def self.roles_to_names(list)
    map_roles(list, :name)
  end

  def self.roles_to_ids(list)
    map_roles(list, :id)
  end

end
