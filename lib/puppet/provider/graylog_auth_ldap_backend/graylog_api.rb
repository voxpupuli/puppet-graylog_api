require_relative '../graylog_api'

Puppet::Type.type(:graylog_auth_ldap_backend).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  attr_writer :role_cache

  attr_accessor :roles_map

  @active_backend_id = nil

  def self.active_backend_id
    @active_backend_id
  end

  def self.active_backend_id=(value)
    @active_backend_id = value
  end

  # self.instances used by puppet resource only
  def self.instances
    if major_version < 4
      fail('graylog_auth_ldap_backend type is not supported in Graylog versions older then 4.x')
    end

    result = get('system/authentication/services/backends')
    self.get_active_backend_id

    items = result['backends'].map do |data|
      # skip non ldap backends
      next unless ['active-directory', 'ldap'].include?(data['config']['type'])
      roles = roles_to_names(data['default_roles'])

      Puppet.debug("In instances: data[id] = #{data['id']} and backend = #{@active_backend_id}")
      #Puppet.debug("In instances: data[id] = #{data['id']} and backend = #{@active_backend_id.nil?}")
      Puppet.debug("In instances: enabled:  #{(!@active_backend_id.nil? and data['id'] == @active_backend_id)}")
      # initializes the @property_hash
      new(
        name:                 data['description'],
        description:          data['description'],
        ensure:               :present,
        enabled:              (!@active_backend_id.nil? and data['id'] == @active_backend_id),
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
        rest_id:              data['id'],
      )
    end
    items.compact
  end

  # and self.prefetch used by puppet apply and agent
  def self.prefetch(resources)
    if major_version < 4
      fail('graylog_auth_ldap_backend type is not supported in Graylog versions older then 4.x')
    end

    # get all instances found on the system
    backends = instances
    resources.keys.each do | name |
      if provider = backends.find{ | bcknd | bcknd.name == name }
        resources[name].provider = provider
      end
    end
  end

#  def enabled
#    active_id = get('system/authentication/services/configuration')['configuration']['active_backend']
#    e = !active_id.nil? and @resource['rest_id'] == active_id
#    Puppet.debug("In enabled getter: returning #{e}")
#    Puppet.debug("In enabled getter: @active_id #{active_id}i and @active_backend_id = #{self.active_backend_id}")
#    Puppet.debug("and the resource in catlogue sets enable to #{resource[:enabled]}")
#    @property_hash[:enabled] = !active_id.nil? and @resource['rest_id'] == active_id
#    Puppet.debug("and the resource_hash is #{@resource.to_hash}")
#    Puppet.debug("and the property-hash is #{@property_hash}")
#    e
#  end

  def system_user_password
    Puppet.debug("In getter System_User_Password resource is #{@resource.to_hash}")
    Puppet.debug("In getter System_User_Password property_hash is #{@property_hash}")
    Puppet.debug("In getter System_User_Password")
    if @resource[:reset_password] or !@property_hash[:password_is_set]
      nil
    else
      @resource[:system_user_password]
    end
  end

  def flush
    Puppet.debug("Flushing graylog_api resources for graylog_auth_ldap_backend with properties: #{@property_hash}")
    Puppet.debug("Flushing graylog_api resources for graylog_auth_ldap_backend with catalogue data: #{@resource.to_hash}")
    Puppet.debug("In Flush: active backend = #{@active_backend_id}")
    #Puppet.debug("Flushing graylog_api resources for graylog_auth_ldap_backend with methods: #{@resource.methods}")
    # we translate the resource properties to the api call data struct
    #

    data = {
      default_roles: self.class.roles_to_ids(@resource[:default_roles]),
      description: @resource[:description],
      title: @resource[:type] == 'ldap' ? 'LDAP' : 'Active Directory',
      config: {
        type: @resource[:type],
        servers: @resource[:server_address].map { |uri|
          a=uri.split(':')
          {
            host: a[0],
            port: a[1],
          }
        },
        transport_security: @resource[:transport_security],
        verify_certificates: @resource[:verify_certificates],
        system_user_dn: @resource[:system_user_dn],
        user_search_base: @resource[:search_base_dn],
        user_search_pattern: @resource[:search_pattern],
        user_full_name_attribute: @resource[:full_name_attribute],
        user_name_attribute: @resource[:name_attribute],
        system_user_password: @resource[:system_user_password],
      }
    }

    Puppet.debug("In FLUSH: rest_id = #{@property_hash[:rest_id]} and backend = #{@active_backend_id.nil?}")
    Puppet.debug("@action => #{@action} - @resource[:enabled] => #{@resource[:enabled]} - @property_hash[:enabled] => #{@property_hash[:enabled]} - Active_backend = #{@active_backend_id}")

    if @action == :destroy and @property_hash[:rest_id].eql? @active_backend_id
      # we need to deactivate this backend before removal.  Otherwise we get the following error:
      # {"type":"ApiError","message":"Authentication service backend <638a2eeca065b64a660fb724> is still in use"}
      post('system/authentication/services/configuration', {active_backend: nil})
    end
    simple_flush('system/authentication/services/backends', data)

    if @action != :create
      params = nil
      if @resource[:enabled] and @action != :destroy
        # Only one active backend is allowed.  When multiple resources have enabled => true
        # the last one in the catlogue will be the active one.
        # When an activa backend is removed, this will also deactivate that backend.  This could lead
        # to no active backends.
        # When enabled => false, we set the active backend to 'null', but only if it is the active backend
        # We cannot ganrantuee that we have an active backend, by the nature of the api calls.
        if @active_backend_id.nil? or  @property_hash[:rest_id] != @active_backend_id
          params = {
            active_backend: @property_hash[:rest_id]
          }
          Puppet.send_log(:info, "FLUSH: GRAYLOG: Activating ldap backend with id: #{@property_hash[:rest_id]}")
        end
      else
        if @property_hash[:rest_id] == @active_backend_id
          params = {
            active_backend: nil
          }
          Puppet.send_log(:info, "FLUSH: GRAYLOG: Deactivating ldap backend with id: #{@property_hash[:rest_id]}")
        end
      end

      if params
        post('system/authentication/services/configuration', params)
      end
    end
  end

  def self.get_active_backend_id
    if !@active_backend_id
      Puppet.debug('In get_active_backend_id - executing Api Call')
      @active_backend_id = get('system/authentication/services/configuration')['configuration']['active_backend']
    end
      Puppet.debug("In get_active_backend_id - Api Call result #{@active_backend_id}")
    @active_backend_id
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
