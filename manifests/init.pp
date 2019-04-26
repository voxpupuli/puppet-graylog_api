# @summary 
#   Sets the API credentials used by the rest of the types in the module.
#
# This sets the API credentials used by the rest of the types in the module
# to communicate with the Graylog API. These are stored on-disk in
# ${confdir}/graylog_api_config.yaml
#
# @param password
#   The password used to authenticate with the Graylog API.
#
# @param port
#   The port on which the API can be reached.
#
# @param username
#   The username used to authenticate with the Graylog API.
class graylog_api(
  String  $password,
  Integer $port     = 9000,
  String  $username = 'admin',
) {
  $config = {
    password => $password,
    port     => $port,
    username => $username,
  }

  file { 'graylog_api_config.yaml':
    path    => "${::confdir}/graylog_api_config.yaml",
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $config.to_yaml,
  }
}
