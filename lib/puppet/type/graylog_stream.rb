require 'puppet/property/boolean'

Puppet::Type.newtype(:graylog_stream) do

  desc <<-END_OF_DOC
    @summary
      Creates a Stream configuration.

    @example
      graylog_stream { 'example':
        description => 'An example stream.',
        rules       => [
          {
            field => 'foo',
            type  => 'equals',
            value => 'bar',
          },
        ],    
      }
  END_OF_DOC

  ensurable

  newparam(:name) do
    desc 'The name of the stream.'
  end

  newproperty(:description) do
    desc 'A description of the stream.'
  end

  newproperty(:enabled, boolean: true, parent: Puppet::Property::Boolean) do
    desc "Whether this stream is enabled."
    defaultto(true)
  end


  newproperty(:matching_type) do
    desc "Whether messages must match all rules, or any rule, to belong to the stream."
    newvalues(:AND, :OR)
    aliasvalue(:and, :AND)
    aliasvalue(:or, :OR)
    aliasvalue(:all, :AND)
    aliasvalue(:any, :OR)
    defaultto(:AND)
  end

  newproperty(:rules, array_matching: :all) do
    desc <<-END_OF_DESC
      An array of rules which messages must match to be routed to this stream.
      Each rule is a hash with the following keys:

        * field       - string, the name of the field being matched
        * type        - string, the type of match being performed; one of: equals, matches, greater_than, less_than, field_presence, contain, or always_match
        * value       - string or number, the value the field is being compared to; set to empty string if no comparison is being made (e.g. for field_presence matcher)
        * inverted    - boolean, whether to negate the match condition
        * description - string, a description of the rule
    END_OF_DESC
    munge do |rule|
      { 'field' => :undef, 'description' => '', 'type' => :undef, 'inverted' => false, 'value' => '' }.merge(rule)
    end
  end

  newproperty(:remove_matches_from_default_stream, boolean: true, parent: Puppet::Property::Boolean) do
    desc "Whether messages that appear in this stream get removed from the default stream."
    defaultto(false)
  end

  newproperty(:index_set) do
    desc "The prefix of the index set that stream operates on."
  end
  # TODO: Implement alert_conditions
  # TODO: Implement alert_receivers
  # TODO: Implement outputs


  autorequire('graylog_api') {'api'}
end
