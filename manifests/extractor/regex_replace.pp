# @summary
#   Defines a Regex replace extractor.
#
# @param ensure
#   Whether this input should exist.
#
# @param input
#   Title of the input this extractor is attached to.
#
# @param source_field
#   Source field
#
# @param target_field
#   Choose a field name to store the extracted value. It can only contain alphanumeric characters and underscores. Example: http_response_code.
#
# @param regex
#   Title of the input this extractor is attached to.
#
# @param cut_or_copy
#   Do you want to copy or cut from source? You cannot use the cutting feature on standard fields like message and source.
#
# @param condition_type
#   Extracting only from messages that match a certain condition helps you avoiding wrong or unnecessary extractions and can also save CPU resources.
#
# @param condition_value
#   Condition value
#
# @param converters
#   A list of optional converter types which must be Java class identifiers of converters, such as org.graylog2.inputs.converters.NumericConverter.
#
# @param order
#   Sort index for this extractor.
#
define graylog_api::extractor::regex_replace (
  Enum['present','absent']  $ensure                    = 'present',
  String                    $input                     = '',
  String                    $source_field              = '',
  String                    $target_field              = '',
  String                    $regex                     = '',
  String                    $replacement               = '',
  Boolean                   $replace_all               = false,
  Optional[String]          $cut_or_copy               = undef,
  Optional[String]          $condition_type            = undef,
  Optional[String]          $condition_value           = undef,
  Optional[Array]           $converters                = undef,
  Optional[Integer]         $order                     = undef
) {
  graylog_extractor { $name:
    ensure          => $ensure,
    input           => $input,
    type            => 'REGEX_REPLACE',
    source_field    => $source_field,
    target_field    => $target_field,
    cut_or_copy     => $cut_or_copy,
    condition_type  => $condition_type,
    condition_value => $condition_value,
    converters      => $converters,
    order           => $order,
    configuration   => {
      regex       => $regex,
      replacement => $replacement,
      replace_all => $replace_all,
    },
  }
}
