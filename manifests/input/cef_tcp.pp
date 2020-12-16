# @summary
#   Defines a CEF-TCP input.
#
# Defines an input accepting CEF messages over TCP.
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
# @param max_message_size
#   The maximum length of a message.
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
# @param tcp_keepalive
#   Whether to enable TCP keepalive packets.
#
# @param timezone
#   The timezone of the timestamps in the CEF messages. Format is TZ Database,
#   e.g. "America/New_York" or "UTC".
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
# @param use_full_names
#   Whether to use full field names in CEF messages (as defined in the CEF
#   specification).
#
# @param use_null_delimiter
#   Whether to use a null byte as a frame delimiter. If false, a newline is
#   used as the delimiter instead.
define graylog_api::input::cef_tcp(
  Enum['present','absent']  $ensure                    = 'present',
  String                    $bind_address              = '0.0.0.0',
  String                    $locale                    = 'en',
  Integer                   $max_message_size          = '2 MB'.to_bytes,
  Integer                   $num_worker_threads        = 2,
  Stdlib::Port              $port                      = 5555,
  Integer                   $recv_buffer_size          = '1 MB'.to_bytes,
  Enum['global','local']    $scope                     = 'global',
  Optional[Hash]            $static_fields             = undef,
  Boolean                   $tcp_keepalive             = false,
  String                    $timezone                  = 'UTC',
  String                    $tls_cert_file             = '',
  String                    $tls_client_auth           = 'disabled',
  String                    $tls_client_auth_cert_file = '',
  Boolean                   $tls_enable                = false,
  String                    $tls_key_file              = '',
  String                    $tls_key_password          = '',
  Boolean                   $use_full_names            = false,
  Boolean                   $use_null_delimiter        = false,
){
  graylog_input { $name:
    ensure        => $ensure,
    type          => 'org.graylog.plugins.cef.input.CEFTCPInput',
    scope         => $scope,
    static_fields => $static_fields,
    configuration => {
      bind_address              => $bind_address,
      locale                    => $locale,
      recv_buffer_size          => $recv_buffer_size,
      port                      => $port,
      tcp_keepalive             => $tcp_keepalive,
      timezone                  => $timezone,
      tls_cert_file             => $tls_cert_file,
      tls_client_auth           => $tls_client_auth,
      tls_client_auth_cert_file => $tls_client_auth_cert_file,
      tls_enable                => $tls_enable,
      tls_key_file              => $tls_key_file,
      tls_key_password          => $tls_key_password,
      use_full_names            => $use_full_names,
      use_null_delimiter        => $use_null_delimiter,
    },
  }
}
