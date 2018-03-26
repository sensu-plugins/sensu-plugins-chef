# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed [here](https://github.com/sensu-plugins/community/blob/master/HOW_WE_CHANGELOG.md)

## [Unreleased]

### Security
- updated yard dependency to `~> 0.9.11` per: https://nvd.nist.gov/vuln/detail/CVE-2017-17042 (@majormoses)

## [5.0.0] - 2018-01-31
### Security
- updated `rubocop` dependency to `~> 0.51.0` per: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-8418. (@geewiz)

### Breaking Change
- in order to bring in new rubocop dependency we need to drop ruby 2.0 support as it is EOL and aligns with our support policy. (@geewiz)

### Fixed
- made exception handling more specific by catching StandardError (@geewiz)
- misc formatting in changelog (@majormoses)

### Changed
- updated changelog guidelines location (@majormoses)


## [4.0.0] - 2017-08-14
### Breaking Change
- check-chef-nodes.rb: added an option for a grace_period which allows exclusion of nodes until they have been online for a specified ammount of time. Defaulting to 300 seconds. (@majormoses)
- check-chef-nodes.rb: when chef has not initially run we can not determine the time that it has been up for nor when it last converged as ohai will not have this information yet. Rather than assuming this is a failure we treat nodes that have no ohai data as not being able to be evaluated. If you are looking for something to catch nodes that fail initial bootstrap I would suggest something along the lines of [aws-watcher](https://github.com/majormoses/aws-watcher)  (@majormoses)


## [3.0.2] - 2017-05-28
## Fixed
- updating runtime deps
## [3.0.1] - 2017-05-09
## Changed
- supress lots of hashie warnings by setting its logger to nil like this: https://github.com/berkshelf/berkshelf/pull/1668/files#diff-3eca4e8b32b88ae6a1f14498e3ef7b25R5 (@babrams)
## [3.0.0] - 2017-05-09
### Breaking Change
- re-wrote all checks to use latest ridley. As ridley 5.x requires buff-extension 2.x which requires >= ruby 2.2 and sensu has never shipped with ruby 2.1 the decision was made to drop this support. If you are not using an embedded ruby and are using 2.1 this will break for you. To avoid this you can either switch to embedded ruby or upgrade your ruby to at least 2.2

# Added
- testing for ruby 2.4

## [2.0.1] - 2017-04-28
### Fixed
- fixed issue with uninitialized constant (@majormoses)

## [2.0.0] - 2017-02-12
### Added
- `check-chef-nodes.rb`: make client name required and set a sane default (@majormoses)

### Removed
- support for Ruby < 2.1.0

### Fixed
- fix travis builds for ruby versions that have older bundler installed (@majormoses)
- `check-chef-nodes.rb`: Fix exclude nodes config (@obazoud)
- `check-chef-nodes.rb`: Fix performance issue with `nodes_last_seen` being called twice when there are failed nodes (@obazoud)

### Changed
- bump Chef gem to 12.12.15 (@mattyjones)

## [1.0.0] - 2016-06-14
### Added
- check-chef-nodes.rb: add an option to "check-chef-nodes" to exclude nodes from check

### Changed
- check-chef-server.rb: loosen regex used to match chef-server-ctl status output
- Rubocop updated to ~> 0.40; automated cleanup applied.

### Removed
- Remove Ruby 1.9.3 support; add Ruby 2.3.0 support

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

## 0.0.2 - 2015-06-02
### Fixed
- added binstubs

### Changed
- removed cruft from /lib

## 0.0.1 - 2015-05-04

### Added
- initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-chef/compare/5.0.0...HEAD
[5.0.0]: https://github.com/sensu-plugins/sensu-plugins-chef/compare/4.0.0...5.0.0
[4.0.0]: https://github.com/sensu-plugins/sensu-plugins-chef/compare/3.0.2...4.0.0
[3.0.2]: https://github.com/sensu-plugins/sensu-plugins-chef/compare/3.0.2...3.0.1
[3.0.1]: https://github.com/sensu-plugins/sensu-plugins-chef/compare/3.0.1...3.0.0
[3.0.0]: https://github.com/sensu-plugins/sensu-plugins-chef/compare/3.0.0...2.0.1
[2.0.1]: https://github.com/sensu-plugins/sensu-plugins-chef/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/sensu-plugins/sensu-plugins-chef/compare/1.0.0...2.0.0
[1.0.0]: https://github.com/sensu-plugins/sensu-plugins-chef/compare/0.0.6...1.0.0
[0.0.6]: https://github.com/sensu-plugins/sensu-plugins-chef/compare/0.0.5...0.0.6
[0.0.5]: https://github.com/sensu-plugins/sensu-plugins-chef/compare/0.0.4...0.0.5
[0.0.4]: https://github.com/sensu-plugins/sensu-plugins-chef/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-chef/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-chef/compare/0.0.1...0.0.2
