# @summary
#   Defines a GELF-UDP input.
#
# Defines an input accepting GELF over UDP.
#
# @param ensure
#   Whether this input should exist.
#
# @param bind_address
#   The IP address to listen on. Defaults to 0.0.0.0.
#
# @param decompress_size_limit
#   The maximum number of bytes of decompressed message data will be accepted
#   in a single POST. Defaults to 8 megabytes.
#
# @param override_source
#   The source is a hostname derived from the received packet by default. Set
#   this if you want to override it with a custom string.
#
# @param port
#   The port to listen on. Defaults to 12280.
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
define graylog_api::input::gelf_udp(
  Enum['present','absent']  $ensure                    = 'present',
  String                    $bind_address              = '0.0.0.0',
  Integer                   $decompress_size_limit     = '8 MB'.to_bytes,
  Optional[String]          $override_source           = undef,
  Stdlib::Port              $port                      = 12201,
  Integer                   $recv_buffer_size          = '256 kB'.to_bytes,
  Enum['global','local']    $scope                     = 'global',
  Optional[Hash]            $static_fields             = undef,
){
  graylog_input { $name:
    ensure        => $ensure,
    type          => 'org.graylog2.inputs.gelf.udp.GELFUDPInput',
    scope         => $scope,
    static_fields => $static_fields,
    configuration => {
      bind_address          => $bind_address,
      decompress_size_limit => $decompress_size_limit,
      recv_buffer_size      => $recv_buffer_size,
      override_source       => $override_source,
      port                  => $port,
    },
  }
}
