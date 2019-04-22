# @summary
#   Loads a full file worth of Grok patterns into Graylog. Since Grok patterns
#   can contain numerous characters that would require escaping in either Hiera
#   data or Puppet code, it's usually more convienient to keep them in their
#   own dedicated files.
#
#   Note that if you load multiple files, and more than one such file defines
#   a pattern with the same name, this will lead to a duplicate declaration
#   error.
#
# @example
#   graylog_api::grok::pattern_file { 'example patterns': 
#     contents => file('profile/graylog/patterns/example_patterns'),
#   }
#
# @param contents
#   A multi-line string containing at most one Grok pattern per line. Lines
#   containing only whitespace, or whose first non-whitespace character is a #,
#   are safely skipped. Actual pattern lines begin with the pattern name in
#   all-caps, followed by a space, followed by the pattern itself. See the
#   Graylog documentation for a full description of the Grok pattern format.
define graylog_api::grok::pattern_file(
  String $contents,
) {
  $contents.split("\n").each |$line| {
    if $line =~ /^\s*#/ { next() }
    if $line =~ /^\s*$/ { next() }
    if $line =~ /^([A-Z0-9_]+) (.+)$/ {
      graylog_grok_pattern { "${1}":
        pattern => $2,
      }
    } else {
      warning("Line not recognized as a valid Grok configuration: ${line}")
    }
  }
}
