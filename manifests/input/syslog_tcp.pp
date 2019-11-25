# @summary
#   Defines a Syslog-TCP input.   
#
# Defines an input accepting Syslog messages over TCP.
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
# @param static_fields
#   Static fields to assign to this input.
#
# @param store_full_message
#   Whether to store the full original syslog message as full_message. Defaults
#   to true.
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
define graylog_api::input::syslog_tcp(
  Enum['present','absent']  $ensure                    = 'present',
  Boolean                   $allow_override_date       = true,
  String                    $bind_address              = '0.0.0.0',
  Boolean                   $expand_structured_data    = true,
  Boolean                   $force_rdns                = false,
  Optional[String]          $override_source           = undef,
  Stdlib::Port              $port                      = 514,
  Integer                   $recv_buffer_size          = '256 kB'.to_bytes,
  Enum['global','local']    $scope                     = 'global',
  Optional[Hash]            $static_fields             = undef,
  Boolean                   $store_full_message        = true,
){
  graylog_input { $name:
    ensure        => $ensure,
    type          => 'org.graylog2.inputs.syslog.udp.SyslogTCPInput',
    scope         => $scope,
    static_fields => $static_fields,
    configuration => {
      allow_override_date    => $allow_override_date,
      bind_address           => $bind_address,
      expand_structured_data => $expand_structured_data,
      force_rdns             => $force_rdns,
      recv_buffer_size       => $recv_buffer_size,
      override_source        => $override_source,
      port                   => $port,
      store_full_message     => $store_full_message,
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
