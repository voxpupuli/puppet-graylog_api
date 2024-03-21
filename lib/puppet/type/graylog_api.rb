# This whole resource type is a weird experimental hack to get the API
# credentials into the catalog without writing them plaintext to disk
# somewhere. It should almost certainly be replaced by a file in /etc like all
# the other similar modules (like the AWS module) do.

require_relative '../provider/graylog_api'

Puppet::Type.newtype(:graylog_api) do
  desc <<-END_OF_DOC
    @summary
      Sets the API credentials used by the rest of the types in the module.

    This sets the API credentials used by the rest of the types in the module
    to communicate with the Graylog API. It does not actually represent a
    concrete resource on the target system.

    @example
      graylog_api { 'api':
        password    => $password,
        tls         => false,
        verify_ssl  => false,
        ssl_ca_file => '/etc/pki/tls/certs/ca-bundle.crt',
        server      => 'graylog.example.com',
        port        => 9000,
        username    => 'admin',
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
      'password'
    end

    def should_to_s(_newvalue)
      'password'
    end

    def is_to_s(_value)
      'password'
    end

    def insync?(_is)
      true
    end
  end

  newproperty('username') do
    desc "The API username used to connect to the Graylog server. Should be the username for the root user (default 'admin')."
    defaultto('admin')

    def retrieve
      'username'
    end

    def insync?(_is)
      true
    end
  end

  newproperty('port') do
    desc 'the api port'
    isrequired

    def retrieve
      'port'
    end

    def insync?(_is)
      true
    end
  end

  newproperty('tls') do
    desc 'enable tls'
    defaultto(false)

    def retrieve
      'tls'
    end

    def insync?(_is)
      true
    end
  end

  newproperty('verify_tls') do
    desc 'enable/disable ssl cert verification'
    defaultto(false)

    def retrieve
      'verify_tls'
    end

    def insync?(_is)
      true
    end
  end

  newproperty('ssl_ca_file') do
    desc 'The certificate authority file'
    defaultto('/etc/pki/tls/certs/ca-bundle.crt')

    #    validate do |value|
    #      unless Puppet::Util.absolute_path?(value)
    #        fail Puppet::Error, _("File paths must be fully qualified, not '%{path}'") % { path: value }
    #      end
    #    end

    def retrieve
      'ssl_ca_file'
    end

    def insync?(_is)
      true
    end
  end

  newproperty('server') do
    desc 'The graylog server hostname'
    defaultto('localhost')

    def retrieve
      'server'
    end

    def insync?(_is)
      true
    end
  end
end
