# This whole resource type is a weird experimental hack to get the API
# credentials into the catalog without writing them plaintext to disk
# somewhere. It should almost certainly be replaced by a file in /etc like all
# the other similar modules (like the AWS module) do.

require_relative '../provider/graylog_api'

Puppet::Type.newtype(:graylog_api) do

  @doc = <<-END_OF_DOC
    This sets the API credentials used by the rest of the types in the module
    to communicate with the Graylog API. It does not actually represent a
    concrete resource on the target system.

    Example:

      graylog_api { 'api':
        password => $password,
        port     => 9000,
        username => 'admin',
      }
  END_OF_DOC

  newparam(:name) do
    desc "must be 'api'"
    newvalues('api')
  end

  newproperty('password') do
    desc 'The API password used to connect to the Graylog server. Should be the password for the root user.'
    isrequired

    def retrieve
      "password"
    end

    def should_to_s(newvalue)
      "password"
    end

    def is_to_s(value)
      "password"
    end

    def insync?(is)
      true
    end
  end

  newproperty('username') do
    desc "The API username used to connect to the Graylog server. Should be the username for the root user (default 'admin')."
    defaultto('admin')

    def retrieve
      'username'
    end

    def insync?(is)
      true
    end
  end

  newproperty('port') do
    desc 'the api port'
    isrequired

    def retrieve
      "port"
    end

    def insync?(is)
      true
    end
  end

end