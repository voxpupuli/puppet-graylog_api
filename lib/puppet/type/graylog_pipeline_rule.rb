require 'puppet/property/boolean'

Puppet::Type.newtype(:graylog_pipeline_rule) do

  desc <<-END_OF_DOC
    Creates a Pipeline Rule. Note that the rule name given in the rule source
    must match the name of the resource as well. You may opt to use the
    graylog_api::pipeline::rule defined type instead, which manages that
    automatically.

    Example:

      graylog_pipeline_rule { 'example':
        description => 'An example rule',
        source      => @(END_OF_RULE),
                       rule "example"
                       when
                         has_field("foo")
                       then
                         set_field("bar","baz");
                       end
                       |-END_OF
      }
  END_OF_DOC

  ensurable

  newparam(:name) do
    desc 'The name of the pipeline rule.'
  end

  newproperty(:description) do
    desc 'A description of the pipeline rule.'
  end

  newproperty(:source) do
    desc 'The source code for the pipeline rule.'
  end

  validate do
    match_data = self[:source].match(/\A\s*rule\s+"(.+?)"/)
    fail("Rule source does not appear to begin with a rule-title declaration!") unless match_data
    inline_name = match_data.captures[0]
    fail("Name in rule source (#{inline_name}) doesn't match resource title (#{self[:name]})!") unless inline_name == self[:name]
  end

  autorequire('graylog_api') {'api'}
end
