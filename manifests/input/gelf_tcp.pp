# @summary
#   Defines a GELF-TCP input.
#
# Defines an input accepting GELF over TCP, optionally encrypted with TLS.
#
# @param ensure
#   Whether this input should exist.
#
# @param bind_address
#   The IP address to listen on.
#
# @param decompress_size_limit
#   The maximum number of bytes of decompressed message data will be accepted
#   in a single POST.
#
# @param max_message_size
#   The maximum length of a message, in bytes. Default value is 2 megabytes.
#
# @param override_source
#   The source is a hostname derived from the received packet by default. Set
#   this if you want to override it with a custom string.
#
# @param port
#   The port to listen on.
#
# @param recv_buffer_size
#   The size in bytes of the recvBufferSize for network connections to this
#   input. Defaults to 1 MB.
#
# @param scope
#   Whether this input is defined on all nodes ('global') or just this node
#   ('local').
#
# @param static_fields
#   Static fields to assign to this input.
#
# @param tcp_keepalive
#   Whether to enable TCP keepalive packets.
#
# @param tls_cert_file
#   The path to the server certificate to use when securing the connection with
#   TLS. Has no effect unless tls_enable is true. Defaults to the empty string.
#   Note that this must be the entire certificate chain, and that Graylog is
#   sensitive to exact formatting of PEM certificates, e.g. there must be a
#   trailing newline.
#
# @param tls_client_auth
#   Whether to use TLS to authenticate clients. Can be 'disabled', 'optional',
#   or 'required'.
#
# @param tls_client_auth_cert_file
#   The path to the file (or directory) which stores the certificates of
#   trusted clients. Has no effect if tls_client_auth is 'disabled' or
#   tls_enable is false.
#
# @param tls_enable
#   Whether to enable TLS for securing the input.
#
# @param tls_key_file
#   The path to the private key which corresponds to the tls_cert_file. Has no
#   effect if tls_enable is false. 
#   Note that for PEM private keys, Graylog is sensitive to exact formatting,
#   e.g. there must be a trailing newline.
#
# @param tls_key_password
#   The password to decrypt to private key specified in tls_key_file. Leave
#   blank if not using TLS, or if the key is not encrypted.
#
# @param use_null_delimiter
#   Whether to use a null byte as a frame delimiter. If false, a newline is
#   used as the delimiter instead.
define graylog_api::input::gelf_tcp(
  Enum['present','absent']  $ensure                    = 'present',
  String                    $bind_address              = '0.0.0.0',
  Integer                   $decompress_size_limit     = '8 MB'.to_bytes,
  Integer                   $max_message_size          = '2 MB'.to_bytes,
  Optional[String]          $override_source           = undef,
  Stdlib::Port              $port                      = 12201,
  Integer                   $recv_buffer_size          = '1 MB'.to_bytes,
  Enum['global','local']    $scope                     = 'global',
  Optional[Hash]            $static_fields             = undef,
  Boolean                   $tcp_keepalive             = false,
  String                    $tls_cert_file             = '',
  String                    $tls_client_auth           = 'disabled',
  String                    $tls_client_auth_cert_file = '',
  Boolean                   $tls_enable                = false,
  String                    $tls_key_file              = '',
  String                    $tls_key_password          = '',
  Boolean                   $use_null_delimiter        = true,
){
  graylog_input { $name:
    ensure        => $ensure,
    type          => 'org.graylog2.inputs.gelf.tcp.GELFTCPInput',
    scope         => $scope,
    static_fields => $static_fields,
    configuration => {
      bind_address              => $bind_address,
      decompress_size_limit     => $decompress_size_limit,
      max_message_size          => $max_message_size,
      recv_buffer_size          => $recv_buffer_size,
      override_source           => $override_source,
      port                      => $port,
      tcp_keepalive             => $tcp_keepalive,
      tls_cert_file             => $tls_cert_file,
      tls_client_auth           => $tls_client_auth,
      tls_client_auth_cert_file => $tls_client_auth_cert_file,
      tls_enable                => $tls_enable,
      tls_key_file              => $tls_key_file,
      tls_key_password          => $tls_key_password,
      use_null_delimiter        => $use_null_delimiter,
    },
  }
}
