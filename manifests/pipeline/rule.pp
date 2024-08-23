# @summary
#   Defines a pipeline rule.
#
# This is a convenience wrapper around graylog_pipeline_rule which ensures no
# mismatch between the name in the rule source and the name of the resource.
#
# @example Creating a pipeline rule
#   graylog_api::pipeline::rule { 'example':
#     description => 'an example rule',
#     condition   => 'has_field("foo")',
#     action      => 'set_field("bar","baz");',
#   }
#
# @param description
#   A description of the rule.
#
# @param condition
#   The condition in the 'when' clause of the rule. Defaults to true, e.g. by
#   default the rule will match all messages.
#
# @param action
#   The action to take if the rule matches. Defaults to the empty string (e.g.
#   no action is taken when the rule matches). 
define graylog_api::pipeline::rule (
  Optional[String] $description = undef,
  String $condition             = 'true', # lint:ignore:quoted_booleans
  Optional[String] $action      = undef
) {
  $rule_body = @("END_OF_RULE")
    rule "${title}"
    when
    ${condition}
    then
    ${action}
    end
    |- END_OF_RULE

  graylog_pipeline_rule { $title:
    description => $description,
    source      => $rule_body,
  }
}
