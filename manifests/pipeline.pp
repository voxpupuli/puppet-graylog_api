define graylog_api::pipeline(
  String                                    $description = '',
  Array[Graylog_api::Pipeline::Stage::Loose] $stages,
  Variant[String,Array[String]]             $streams     = [],
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
