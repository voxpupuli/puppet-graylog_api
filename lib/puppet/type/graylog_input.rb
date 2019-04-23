Puppet::Type.newtype(:graylog_input) do

  desc <<-END_OF_DOC
    Creates a new input. This type covers the raw API and is agnostic to the
    type of input being created. In most cases, you should declare inputs using
    the graylog_api::input::* defined types, which wrap this type and provide
    properties for input-type-specific configuration. You can use this type
    directly to configure an input type that doesn't have an existing wrapper.

    Example:

      graylog_input { 'Example Beats input':
        ensure        => present,
        type          => 'org.graylog.plugins.beats.BeatsInput',
        scope         => 'global',
        configuration => {
          bind_address              => '0.0.0.0',
          recv_buffer_size          => '8 MB'.to_bytes,
          override_source           => 'Example override',
          port                      => 5044,
          tcp_keepalive             => false,
          tls_cert_file             => '',
          tls_client_auth           => false,
          tls_client_auth_cert_file => '',
          tls_enable                => false,
          tls_key_file              => '',
          tls_key_password          => '',
        },
      }
  END_OF_DOC

  ensurable

  newparam(:name) do
    desc 'The name of the Input Source'
  end

  newproperty(:type) do
    desc 'The type of the Input. Must be the Java class identifier for the input, such as org.graylog.plugins.beats.BeatsInput.'
  end

  newproperty(:scope) do
    desc "Whether this input is defined on all nodes ('global') or just this node ('local')."
    newvalues(:local, :global)
    defaultto(:global)
  end

  newproperty(:configuration) do
    desc "A hash of configuration values for the input; structure varies by input type."
    isrequired
  end

  autorequire('graylog_api') {'api'}
end
