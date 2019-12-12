[![Sensu Bonsai Asset](https://img.shields.io/badge/Bonsai-Download%20Me-brightgreen.svg?colorB=89C967&logo=sensu)](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-chef)
[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-chef.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-chef)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-chef.svg)](http://badge.fury.io/rb/sensu-plugins-chef)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-chef/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-chef)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-chef/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-chef)

## Sensu Plugins Chef Plugin

- [Overview](#overview)
- [Files](#files)
- [Usage examples](#usage-examples)
- [Configuration](#configuration)
  - [Sensu Go](#sensu-go)
    - [Asset registration](#asset-registration)
    - [Asset definition](#asset-definition)
    - [Check definition](#check-definition)
  - [Sensu Core](#sensu-core)
    - [Check definition](#check-definition)
- [Installation from source](#installation-from-source)
- [Additional notes](#additional-notes)
- [Contributing](#contributing)

### Overview

This plugin provides native instrumentation for monitoring Chef, including service health checks (via chef-server-ctl) and chef node status, and a Sensu handler for removing stale Sensu clients.

### Files
 * bin/check-chef-node.rb
 * bin/check-chef-nodes.rb
 * bin/check-chef-server.rb
 * bin/handler-chef-node.rb
 
**check-chef-node**
Checks if a node exists.

**check-chef-nodes**
Reports nodes from your cluster that were last seen before the specified number of seconds.

**check-chef-server**
Uses Chef Server's `chef-server-ctl` to check whether any component of the Chef Server is not running. You must run this plugin with elevated privileges (sudo) or it will fail with unknown state.

**handler-chef-node**
Removes a Sensu client if its Chef node data no longer exists.

## Usage examples

### Help

**check-chef-node.rb**
```
Usage: check-chef-node.rb (options)
    -U, --url CHEF-SERVER-URL        URL of Chef server
    -C, --client CLIENT-NAME         Client name
    -i, --ignore-ssl                 Ignore SSL certificate verification
    -K, --keys CLIENT-KEY            Client's key
    -n, --node-name NODE-NAME        Check if this node name exists
```

**handler-chef-node.rb**
```
Usage: handler-chef-node.rb (options)
        --map-go-event-into-ruby     Enable Sensu Go to Sensu Ruby event mapping. Alternatively set envvar SENSU_MAP_GO_EVENT_INTO_RUBY=1.

```

## Configuration
### Sensu Go
#### Asset registration

Assets are the best way to make use of this plugin. If you're not using an asset, please consider doing so! If you're using sensuctl 5.13 or later, you can use the following command to add the asset: 

`sensuctl asset add sensu-plugins/sensu-plugins-chef`

If you're using an earlier version of sensuctl, you can download the asset definition from [this project's Bonsai asset index page](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-chef).

#### Asset definition

```yaml
---
type: Asset
api_version: core/v2
metadata:
  name: sensu-plugins-chef
spec:
  url: https://assets.bonsai.sensu.io/94e44dc0b89b7cd8318c38db5f64f788642140d8/sensu-plugins-chef_7.0.0_centos_linux_amd64.tar.gz
  sha512: f468ea0060ab890004a3f5bd09deff5bdd98db9e7a4c9ffc0ad1c8809b0e5a8198737f23ec850e9f5181fd590aafa5b895dd948b264244770c77b5f03fa523ef
```

#### Check definition

```yaml
---
type: CheckConfig
spec:
  command: "check-chef-nodes.rb"
  handlers: []
  high_flap_threshold: 0
  interval: 10
  low_flap_threshold: 0
  publish: true
  runtime_assets:
  - sensu-plugins/sensu-plugins-chef
  - sensu/sensu-ruby-runtime
  subscriptions:
  - linux
```

### Sensu Core

#### Check definition
```json
{
  "checks": {
    "check-chef-nodes": {
      "command": "check-chef-nodes.rb",
      "subscribers": ["linux"],
      "interval": 10,
      "refresh": 10,
      "handlers": ["influxdb"]
    }
  }
}
```

## Installation from source

### Sensu Go

See the instructions above for [asset registration](#asset-registration).

### Sensu Core

Install and setup plugins on [Sensu Core](https://docs.sensu.io/sensu-core/latest/installation/installing-plugins/).

## Additional notes

### Sensu Go Ruby Runtime Assets

The Sensu assets packaged from this repository are built against the Sensu Ruby runtime environment. When using these assets as part of a Sensu Go resource (check, mutator, or handler), make sure to include the corresponding [Sensu Ruby Runtime Asset](https://bonsai.sensu.io/assets/sensu/sensu-ruby-runtime) in the list of assets needed by the resource.

### Use this plugin with Sensu Go

To use `handler-chef-node.rb` with Sensu Go, you will need to use the event mapping command line option. See `handler-chef-node.rb --help` for details. Read the [sensu-plugin README](https://github.com/sensu-plugins/sensu-plugin#sensu-go-enablement) for more information about the event mapping functionality.

## Contributing

See [CONTRIBUTING.md](https://github.com/sensu-plugins/sensu-plugins-chef/blob/master/CONTRIBUTING.md) for information about contributing to this plugin.
