Puppet::Type.newtype(:graylog_grok_pattern) do
  desc <<~END_OF_DOC
    @summary
       Installs a Grok pattern.
    
    Installs a Grok pattern. Note that when representing Grok patterns in
    Puppet code or YAML-formatted Hiera data, extra escaping is necessary for
    many regex characters. Thus, it is often more convenient to use the
    graylog_api::grok::pattern_file defined type to define Grok patterns in
    their own dedicated file.

    @see graylog_api::grok::pattern

    @example
      graylog_grok_pattern { 'EXAMPLE':
        pattern => '%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level_name} %{GREEDYDATA:message}',
      }
  END_OF_DOC

  ensurable

  newparam(:name) do
    desc 'The token that represents the pattern. Must be in all-caps.'
    validate do |value|
      raise ArgumentError, "Pattern token must match /[A-Z0-9_]+/" unless value =~ /[A-Z0-9_]+/
    end
  end

  newproperty(:pattern) do
    desc 'The literal pattern string.'
  end

  autorequire('graylog_api') {'api'}
end
