require 'puppet/property/boolean'

Puppet::Type.newtype(:graylog_pipeline) do

  desc <<-END_OF_DOC
    Creates a processing pipeline. This type takes the pipeline definition as
    source text; note that the pipeline name in the source text must match the
    resource title. Overall, you may find it more convenient to use the
    graylog_api::pipeline defined type, which can take care of this for you, as
    well as accepting e.g. an array of rules to apply rather than source text.

    Example:

      graylog_pipeline { 'example pipeline':
        description       => 'An example processing pipleine',
        source            => @(END_OF_PIPELINE),
                            pipeline "everity"
                            stage 3 match either
                              rule "foo";
                              rule "bar";
                            stage 5 match all
                              rule "baz";
                            end
                            |-END_OF_PIPELINE
        connected_streams => ['All messages'],
      }
  END_OF_DOC

  ensurable

  newparam(:name) do
    desc 'The name of the processing pipeline.'
  end

  newproperty(:description) do
    desc 'A description of the processing pipeline.'
  end

  newproperty(:source) do
    desc 'The source code for the processing pipeline.'
  end

  newproperty(:connected_streams, array_matching: :all) do
    desc "Streams to process with this pipeline. Note that case matters, here. \
    Also note that, if the Pipeline Processor is running before the Message \
    Filter Chain, then the only stream that will have messages at processing \
    time will be the 'All messages' stream."
  end

  validate do
    match_data = self[:source].match(/\A\s*pipeline\s+"(.+?)"/)
    fail("Pipeline source does not appear to begin with a pipeline-title declaration!") unless match_data
    inline_name = match_data.captures[0]
    fail("Name in pipeline source (#{inline_name}) doesn't match resource title (#{self[:name]})!") unless inline_name == self[:name]
  end

  autorequire('graylog_api') { 'api' }
  autorequire('graylog_stream') { self[:connected_streams] }
end
