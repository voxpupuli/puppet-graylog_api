# @summary
#   Defines a Syslog-UDP input.   
#
# Defines an input accepting Syslog messages over UDP.
#
# @param ensure
#   Whether this input should exist.
#
# @param allow_override_date
#   Whether to allow setting the message timestamp to the current server time,
#   if the timstamp in the message failed to parse. Defaults to true.
#
# @param bind_address
#   The IP address to listen on. Defaults to 0.0.0.0.
#
# @param expand_structured_data
#   Whether to expand structured data elements by prefixing attributes with
#   their SD-ID. Defaults to true.
#
# @param force_rdns
#   Whether to force reverse DNS resolution of sender's hostname. Use if the 
#   hostname in the message cannot be parsed. Default value is false.
#   NOTE: Be careful with this setting if you are sending DNS server logs into
#   this input as it can cause a feedback loop.
#
# @param override_source
#   The source is a hostname derived from the received packet by default. Set
#   this if you want to override it with a custom string.
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
# @param store_full_message
#   Whether to store the full original syslog message as full_message. Defaults
#   to true.
define graylog_api::input::syslog_udp(
  Enum['present','absent']  $ensure                    = 'present',
  Boolean                   $allow_override_date       = true,
  String                    $bind_address              = '0.0.0.0',
  Boolean                   $expand_structured_data    = true,
  Boolean                   $force_rdns                = false,
  Optional[String]          $override_source           = undef,
  Stdlib::Port              $port                      = 514,
  Integer                   $recv_buffer_size          = '256 kB'.to_bytes,
  Enum['global','local']    $scope                     = 'global',
  Boolean                   $store_full_message        = true,
){
  graylog_input { $name:
    ensure        => $ensure,
    type          => 'org.graylog2.inputs.syslog.udp.SyslogUDPInput',
    scope         => $scope,
    configuration => {
      allow_override_date       => $allow_override_date,
      bind_address              => $bind_address,
      expand_structured_data    => $expand_structured_data,
      force_rdns                => $force_rdns,
      recv_buffer_size          => $recv_buffer_size,
      override_source           => $override_source,
      port                      => $port,
      store_full_message        => $store_full_message,
    },
  }
}
