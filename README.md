## Sensu-Plugins-chef

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-chef.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-chef)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-chef.svg)](http://badge.fury.io/rb/sensu-plugins-chef)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-chef/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-chef)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-chef/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-chef)
[![Sensu Bonsai Asset](https://img.shields.io/badge/Bonsai-Download%20Me-brightgreen.svg?colorB=89C967&logo=sensu)](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-chef)

## Sensu Asset  
  The Sensu assets packaged from this repository are built against the Sensu ruby runtime environment. When using these assets as part of a Sensu Go resource (check, mutator or handler), make sure you include the corresponding Sensu ruby runtime asset in the list of assets needed by the resource.  The current ruby-runtime assets can be found [here](https://bonsai.sensu.io/assets/sensu/sensu-ruby-runtime) in the [Bonsai Asset Index](bonsai.sensu.io).


## Functionality

## Files
 * bin/check-chef-nodes.rb
 * bin/check-chef-node.rb
 * bin/check-chef-server.rb
 * bin/handler-chef-node.rb

## Usage

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

## Notes
When using `handler-chef-node.rb` with Sensu Go, you will need to use the event mapping commandline option, see `handler-chef-node.rb --help` for details. And please read [the sensu-plugin README](https://github.com/sensu-plugins/sensu-plugin#sensu-go-enablement) for more information on the event mapping functionality.
