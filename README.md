# graylog_api

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with graylog_api](#setup)
    * [What graylog_api affects](#what-graylog_api-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with graylog_api](#beginning-with-graylog_api)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

This module allows you to use Graylog's REST API to adjust its configuration.
It picks up where the official graylog module leaves off.

## Setup

### What graylog_api affects

This module manages configuration aspects of Graylog that can only be adjusted
via the REST API. This includes:

* LDAP Authentication
* SSO Authentication
* Static users
* User roles
* Inputs
* Streams
* Pipelines and Pipeline rules
* Extractors
* Lookup Tables, Data Adapters and Caches
* Grok Patterns
* Dashboards
* Index Sets

More components of Graylog configuration are in scope for this module, but they
have not been implemented yet.

### Setup Requirements

The Ruby installation used by the Puppet agent on the Graylog server will need
to have the `httparty` and `retries` gems installed. The easiest way to manage
this is to use a `package` resource with the `puppet_gem` provider:

```puppet
package { ['httparty','retries']:
  ensure   => present,
  provider => 'puppet_gem',
}
```

The server will also need to have Graylog installed, of course. For this we
recommend the official graylog-graylog module.

### Beginning with graylog_api

In order to use any of the resources contained in this module, you first need
to supply the credentials the module should use to access the REST API. In
general, this should be the root credentials. Provide these through the
`graylog_api` resource.

```puppet
graylog_api { 'api':
  username => 'admin',
  password => $password,
  port     => 9000,
}
```

The resource title here _must_ be `'api'`.

#### Supplying the password
This module requires the graylog root password in cleartext in order to be able
to authenticate to the API. The official graylog module, on the other hand,
only needs the password hash. Rather than storing both the password and the
hash, we recommend storing the password in Hiera using EYAML, and computing the
hash using Puppet's built-in `sha256` function.

## Usage

### Configure the default index set

```puppet
graylog_index_set { 'graylog':
  description                => 'The Graylog default index set',
  display_name               => 'Default index set',
  shards                     => 1,
  replicas                   => 0,
  rotation_strategy          => 'size',
  rotation_strategy_details  => {
    max_size => '10 GB'.to_bytes,
  },
  retention_strategy         => 'delete',
  retention_strategy_details => {
    max_number_of_indices => 10,
  },
}
```

### Configure inputs

```puppet
# Default properties are often acceptable
graylog_api::input::gelf_tcp { 'A GELF TCP Input': }

# But you can customize if you want
graylog_api::input::gelf_tcp { 'A GELF TCP Input with TLS':
  port          => 12202,
  tls_cert_file => '/etc/graylog/server/tls/cert.pem',
  tls_enable    => true,
  tls_key_file  => '/etc/graylog/server/tls/key.pem',
}
```

### Load Grok Patterns

```puppet
# Load a single pattern
graylog_grok_pattern { 'SOMEFORMAT':
  pattern => '%{WORD:username} %{IP:ipaddress} %{GREEDYDATA:message}',
}

# Or load a bunch of patterns from a pattern file
graylog_api::grok::pattern_file { 'common patterns':
  content => file('profile/graylog/patterns/common),
}
```

### Set up processing pipelines

```puppet
# First set up some rules
graylog_api::pipeline::rule { 'copy message to full_message':
  description => 'Copy the message field to the full_message field before performing extraction',
  condition   => 'has_field("message") && has_field("log_format") && !has_field("full_message")',
  action      => 'set_field("full_message",$message.message);',
}

graylog_api::pipeline::rule { 'parse log format':
  description => 'Parse log via GROK if log_format field is provided',
  condition   => 'has_field("log_format")',
  action      => @(END_OF_ACTION),
                 let format_name = uppercase(to_string($message.log_format));
                 let pattern = concat(concat("%{",format_name),"}");
                 let map = grok(pattern: pattern, value: to_string($message.message), only_named_captures: true);
                 remove_field("log_format");
                 set_fields(map);
                 |-END_OF_ACTION
}

# Then put those rules in a pipeline
graylog_api::pipeline { 'custom log formats':
  description       => "Parse custom log formats",
  stages            => [
    'copy message to full_message',
    'parse log format'
  ],
  connected_streams => ['All messages'],
}
```

## Limitations

There are a lot of different settings in Graylog that this module cannot yet
manage. Essentially it only manages those settings that we've needed so far
ourselves.

This module aims for compatibility with Graylog 3.x, and specifically has been
tested with Graylog 3.1.x. It probably works on later versions of Graylog 3.x
but may not work with 4.x or 2.x.

If you discover any issues, please report them at
https://github.com/magicmemories/puppet-graylog_api/issues

## License and Authorship

This module was authored by Adam Gardner, and is Copyright (c) 2019 Magic Memories (USA) LLC.

It is distributed under the terms of the Apache-2.0 license; see the LICENSE file for details.