  Puppet::Type.newtype(:graylog_user) do

      desc <<-END_OF_DOC
        @summary
          Creates a internal user

        A user definition. Note that the admin user is built-in an cannot be changed.

        @example
          graylog_user { 'test':
            password    => 'B1GnbfoNp9PND6ihXfZFjg',
            full_name   => 'Test user',
            email       => 'foo@bar',
            roles => [
              'Reader'
            ]
          }
      END_OF_DOC

      ensurable

      newparam(:name) do
        desc 'The name of the user'
      end

      newparam(:password) do
        desc 'User password'
        sensitive
      end

      newproperty(:email) do
          desc 'User email address'
          isrequired
      end

      # this proerty is only available in 3.x or older
      newproperty(:full_name) do
          desc 'Full name of the user'
          isrequired
      end

     # next to ptoperties are onlu available in +4.x
     newproperty(:last_name) do
       desc 'Last name of the user'
     end

     newproperty(:first_name) do
       desc 'first name of the user'
     end

      newproperty(:roles, :array_matching => :all) do
          desc 'User roles'
          isrequired
      end

      newproperty(:session_timeout_ms) do
        desc 'Session timeout'
        isrequired
      end

      newproperty(:permissions, :array_matching => :all) do
          desc 'User permissions'
          defaultto([])
      end

      newproperty(:timezone) do
          desc 'User timezone'
      end

      newproperty(:startpage) do
          desc 'User startpage'
      end

      autorequire('graylog_api') {'api'}
    end
