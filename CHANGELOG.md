#Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## Unreleased

## [0.0.6] - 2015-12-03
### Changed
- changed default time before a check is deemed critical to 38 minutes to match the chef-client cookbook (30 min + 5 in splay + 3 for converge)

## [0.0.5] - 2015-11-24
### Added
- add a check if a node exists

### Changed
- pin to varia_model 0.4.1 for Ruby 1.9.3 compatability

## [0.0.4] - 2015-09-03
### Changed
- bumped chef gem to version chef-11.18.12

## [0.0.3] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0

## 0.0.1 - 2015-05-04

### Added
- initial release

## 0.0.2 - 2015-06-02

### Fixed
- added binstubs

### Changed
- removed cruft from /lib
