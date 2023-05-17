Puppet::Type.newtype(:graylog_extractor) do

    desc <<-END_OF_DOC
      @summary
        Creates an Extractor.

      This type covers the raw API and is agnostic to the type of extractor being
      created. In most cases, you should declare extractors using the
      graylog_api::extractor::* defined types, which wrap this type and provide
      properties for extractor-type-specific configuration. You can use this type
      directly to configure an extractor type that doesn't have an existing wrapper.

      @example
        graylog_extractor { 'Example Regex extractor':
          ensure        => present,
          input         => 'Syslog TCP',
          type          => 'org.graylog2.inputs.extractors.RegexExtractor',
          source_field  => 'message'
          target_field  => 'foo'
          configuration => {
            value                     => '^#(.*)'
          },
        }
    END_OF_DOC

    ensurable

    newparam(:name) do
      desc 'A descriptive name for this extractor.'
    end

    newproperty(:input) do
      desc 'Title of the input this extractor is attached to.'
      isrequired
    end

    newproperty(:type) do
      desc 'The type of the Extractor. Must be the Java enum constant for the extractor, such as REGEX'
      isrequired
      munge do |value|
        value.downcase
      end
    end

    newproperty(:source_field) do
      desc 'Source field'
      isrequired
    end

    newproperty(:target_field) do
      desc 'Choose a field name to store the extracted value. It can only contain alphanumeric characters and underscores. Example: http_response_code.'
      isrequired
    end

    newproperty(:configuration) do
      desc 'A hash of configuration values for the extractor; structure varies by extractor type.'
      isrequired
    end

    newproperty(:cut_or_copy) do
      desc 'Do you want to copy or cut from source? You cannot use the cutting feature on standard fields like message and source.'
      newvalues(:copy, :cut)
      defaultto(:copy)
    end

    newproperty(:condition_type) do
      desc 'Extracting only from messages that match a certain condition helps you avoiding wrong or unnecessary extractions and can also save CPU resources.'
      newvalues(:none, :regex, :string)
      defaultto(:none)
    end

    newproperty(:condition_value) do
      desc 'Condition value'
      defaultto('')
    end

    newproperty(:converters) do
      desc 'A list of optional converter types which must be Java class identifiers of converters, such as org.graylog2.inputs.converters.NumericConverter'
      defaultto({})
    end

    newproperty(:order) do
      desc 'Sort index for this extractor'
      #defaultto(0)
    end

    autorequire('graylog_api') {'api'}
  end
