require_relative '../graylog_api'

Puppet::Type.type(:graylog_auth_ldap_backend).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  has_feature :activateable

  mk_resource_methods

  attr_writer :role_cache

  attr_accessor :roles_map

  def self.instances
    if major_version < 4
      fail('graylog_auth_ldap_backend type is not supported in Graylog versions older then 4.x')
    end

    result = get('system/authentication/services/backends')

    items = result['backends'].map do |data|
      # skip non ldap backends
      next unless ['active-directory', 'ldap'].include?(data['config']['type'])
      roles = roles_to_names(data['default_roles'])

      new(
        name:                 data['description'],
        description:          data['description'],
        ensure:               :present,
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

  def self.prefetch(resources)
    if major_version < 4
      fail('graylog_auth_ldap_backend type is not supported in Graylog versions older then 4.x')
    end

    backends = instances
    resources.keys.each do | name |
      if provider = backends.find{ | bcknd | bcknd.name == name }
        resources[name].provider = provider
      end
    end
  end

  def activated_insync?(current)
    current == @resource[:activated]
  end

  def activate
    params = { active_backend: @property_hash[:rest_id] }
    post('system/authentication/services/configuration', params)
    @property_hash[:activated] = :true
  end

  def deactivate
    # we need to check the active backend each time, since another resource can be (de)activated in the meantime
    active_backend_id = get('system/authentication/services/configuration')['configuration']['active_backend']
    if !active_backend_id.nil? and @property_hash[:rest_id] == active_backend_id
      post('system/authentication/services/configuration', { active_backend: nil })
    end
    @property_hash[:activated] = :false
  end

  def activated?
    @property_hash[:activated]
  end

  def activated
    active_backend_id = get('system/authentication/services/configuration')['configuration']['active_backend']
    @property_hash[:activated] = (!active_backend_id.nil? and @property_hash[:rest_id] == active_backend_id).to_s.to_sym
  end

  def system_user_password
    if @resource[:reset_password] or !@property_hash[:password_is_set]
      nil
    else
      @resource[:system_user_password]
    end
  end

  def flush

    data = {
      default_roles: self.class.roles_to_ids(@resource[:default_roles]),
      description: @resource[:description],
      title: @resource[:type] == :ldap ? 'LDAP' : 'Active Directory',
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

    if @action == :destroy
      # we cannot remove an active backend, so we deactivate it first
      deactivate
    end

    if @action.nil? and type != @initial_params[:type]
      # the type cannot be changed, so we remove backend first, and then create a new one
      # needs to be deactivated before removal
      if activated? == :true
        deactivate
      end
      delete("system/authentication/services/backends/#{rest_id}")
      response = post('system/authentication/services/backends', data)
      set_rest_id_on_create(response) if respond_to?(:set_rest_id_on_create)
      # and set it activated after recreation if needed
      if @resource[:activated] == :true
        @property_hash[:rest_id] = @rest_id
        activate
      end
    else
      simple_flush('system/authentication/services/backends', data)
      if @action == :create and @resource[:activated]
        # new created backends should be activated after initial creation if needed
        @property_hash[:rest_id] = @rest_id
        activate
      end
    end
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
