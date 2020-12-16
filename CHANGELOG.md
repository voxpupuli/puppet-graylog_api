# Changelog

All notable changes to this project will be documented in this file.

This project follows [Semantic Versioning](https://semver.org/). Since it is
currently a 0.x release, no aspect of the public API is guaranteed to be stable
between versions, even minor versions.

## Reelase 0.4.1
** New Features **
* New graylog_api::inputs::cef_tcp input class.
* New graylog_api::inputs::cef_udp input class.

## Release 0.4.0
** New Features **
* New graylog_extractor type [(#2)](https://github.com/magicmemories/puppet-graylog_api/pull/2)
* New graylog_plugin_auth_sso type [(#2)](https://github.com/magicmemories/puppet-graylog_api/pull/2)
* New graylog_user type [(#2)](https://github.com/magicmemories/puppet-graylog_api/pull/2)

** Enhancements **
* graylog_index_set type now has a `disable_index_optimization` parameter [(#2)](https://github.com/magicmemories/puppet-graylog_api/pull/2)
* graylog_role provider now automatically maps permissions names of the form `streams:streamname`
  rather than requiring the stream ID be embedded in the data passed in. [(#2)](https://github.com/magicmemories/puppet-graylog_api/pull/2)

** Bugfixes **
* Updating rules for existing streams now works properly [(#2)](https://github.com/magicmemories/puppet-graylog_api/pull/2)

## Release 0.3.0
** New features **
* New graylog_api::input::syslog_tcp type [(#1)](https://github.com/magicmemories/puppet-graylog_api/pull/1)

## Release 0.2.1
** Bugfixes **
* Remove leftover debugging code.

## Release 0.2.0
** New features **
* graylog_input and graylog_api::input::* now support a static_fields property.

## Release 0.1.3
** Bugfixes **
* Fixed an issue updating Lookup Tables and Lookup Caches
* Fixed an issue minor issue with stream rules that don't use the Value attribute.

## Release 0.1.2
** Bugfixes **
* Fixed issue introduced by namevar not being called 'name' for the
  `graylog_index_set` property.

## Release 0.1.1
** Breaking Changes **
* `graylog_index_set` now uses the `prefix` property as its namevar, and the
  `name` property has been renamed to `display_name`. This fits better with the
  fact that the prefix is unique and immutable, and the display name is not.
* Accordingly, the `index_set` property of the `graylog_stream` data type now
  refers to the prefix of the associated index set, and not its display name.

## Release 0.1.0
Initial Release
