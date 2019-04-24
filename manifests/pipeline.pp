# @summary
#   Define a processing pipeline. 
#
# This is a convenience wrapper around graylog_pipeline, which prevents frees
# you from worrying about pipeline syntax.
#
# @note
#   This class is a work in progress in many ways. It's probably smarter
#   to use graylog_pipeline directly until this has been fleshed out more.
#   The main problem is that this defined type doesn't allow assigning stages
#   an explicit priority, insteading giving them priority in order counting
#   from 1.
#
# @example Creating a pipeline where each stage is a single rule
#   graylog_api::pipeline { 'example',
#     description => 'an example pipeline',
#     stages      => [
#       'rule 1',
#       'rule 2',
#     ],
#     streams     => ['All messages'],
#   }
#
# @example Creating a pipeline where each stage has multiple rules
#   graylog_api::pipeline { 'example': 
#     description => 'an example pipeline',
#     stages      => [
#       ['rule 1a', 'rule 1b'],
#       ['rule 2a', 'rule 2b'],
#     ],
#     streams     => ['All messages'],
#   }
#
# @example Creating a pipeline where stages have explicit match types
#   graylog_api::pipeline { 'example': 
#     description => 'an example pipeline', 
#     stages      => [
#       {
#         match => 'all',
#         rules => ['rule 1a', 'rule 1b'],
#       },
#       {
#         match => 'either',
#         rules => ['rule 2a', 'rule 2b'],
#       },
#     ],
#     streams     => ['All messages'],
#   }
#
# @param description
#   The description of the pipeline.
#
# @param stages
#   An array of stages. Each stage can be either:
#
#     * A rule name - This rule will be given a stage to itself.
#     * An array of rule names - These will be placed in a 'match all' stage.
#     * A hash with two keys:
#       + match - the match type of the stage, either 'all' or 'either'
#       + rules - An array of rules in the stage.
#
#   Stage priority cannot be set manually using this defined type; the first
#   stage in the array will be stage 1, the second stage 2, etc. If you need to
#   set explicit stage priorities to control how multiple pipelines run in
#   parallel, use the graylog_pipeline native type directly.
#
# @param streams
#   An array of Stream names to connect the pipeline to. Note that these are
#   case-sensitive. Also note that, if the Pipeline Processor is running before
#   the Message Filter Chain, then the only stream that will have messages at
#   processing time will be the 'All messages' stream.
define graylog_api::pipeline(
  String                                     $description = '',
  Array[Graylog_api::Pipeline::Stage::Loose] $stages,
  Variant[String,Array[String]]              $streams     = [],
) {
  $stage_bodies = $stages.map |$index,$stage| {
    $true_stage = $stage ? {
      Graylog_api::Pipeline::Stage => $stage,
      default                     => { match => 'all', rules => Array($stage,true) },
    }
    $rule_bodies = $true_stage['rules'].map |$rule| { "  rule \"${rule}\";" }
    $rules_body = $rule_bodies.join("\n")
    "stage ${$index+1} match ${true_stage['match']}\n${rules_body}"
  }

  $stages_body = $stage_bodies.join("\n")

  $pipeline_body = @("END_OF_PIPELINE")
    pipeline "${title}"
    ${stages_body}
    end
    |- END_OF_PIPELINE

  graylog_pipeline { $title:
    description       => $description,
    source            => $pipeline_body,
    connected_streams => Array($streams,true),
  }
}
