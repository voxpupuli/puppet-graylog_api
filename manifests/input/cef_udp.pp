# @summary
#   Defines a CEF-UDP input.
#
# Defines an input accepting CEF messages over UDP.
#
# @param ensure
#   Whether this input should exist.
#
# @param bind_address
#   The IP address to listen on. Defaults to 0.0.0.0.
#
# @param locale
#   The locale to use when parsing the CEF timestamps. Format can be either
#   "en"-style or "en_US"-style.
#
# @param num_worker_threads
#   How many worker threads the input should use.
#
# @param port
#   The port to listen on. Defaults to 514, however be aware that in many
#   server setups Graylog will not be able a privileged port without additional
#   configuration.
#
# @param recv_buffer_size
#   The size in bytes of the recvBufferSize for network connections to this
#   input. Defaults to 256 kilobytes.
#
# @param scope
#   Whether this input is defined on all nodes ('global') or just this node
#   ('local'). Default is global.
#
# @param static_fields
#   Static fields to assign to this input.
#
# @param timezone
#   The timezone of the timestamps in the CEF messages. Format is TZ Database,
#   e.g. "America/New_York" or "UTC".
#
# @param use_full_names
#   Whether to use full field names in CEF messages (as defined in the CEF
#   specification).
#
# @param use_null_delimiter
#   Whether to use a null byte as a frame delimiter. If false, a newline is
#   used as the delimiter instead.
define graylog_api::input::cef_udp (
  Enum['present','absent']  $ensure                    = 'present',
  String                    $bind_address              = '0.0.0.0',
  String                    $locale                    = 'en',
  Integer                   $num_worker_threads        = 2,
  Stdlib::Port              $port                      = 5555,
  Integer                   $recv_buffer_size          = '1 MB'.to_bytes,
  Enum['global','local']    $scope                     = 'global',
  Optional[Hash]            $static_fields             = undef,
  String                    $timezone                  = 'UTC',
  Boolean                   $use_full_names            = false,
) {
  graylog_input { $name:
    ensure        => $ensure,
    type          => 'org.graylog.plugins.cef.input.CEFTCPInput',
    scope         => $scope,
    static_fields => $static_fields,
    configuration => {
      bind_address     => $bind_address,
      locale           => $locale,
      recv_buffer_size => $recv_buffer_size,
      port             => $port,
      timezone         => $timezone,
      use_full_names   => $use_full_names,
    },
  }
}
