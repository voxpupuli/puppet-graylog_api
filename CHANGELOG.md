# Changelog

All notable changes to this project will be documented in this file.

This project follows [Semantic Versioning](https://semver.org/). Since it is
currently a 0.x release, no aspect of the public API is guaranteed to be stable
between versions, even minor versions. 

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
