## Sensu-Plugins-chef

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-chef.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-chef)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-chef.svg)](http://badge.fury.io/rb/sensu-plugins-chef)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-chef/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-chef)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-chef/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-chef)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-chef.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-chef)
[ ![Codeship Status for sensu-plugins/sensu-plugins-chef](https://codeship.com/projects/9ffac250-d4b5-0132-cbb6-0e210ac4c62f/status?branch=master)](https://codeship.com/projects/77870)

## Functionality

## Files
 * bin/check-chef-nodes
 * bin/check-chef-server
 * bin/handler-chef-node

## Usage

## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install sensu-plugins-chef -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

#### Rubygems

`gem install sensu-plugins-chef`

#### Bundler

Add *sensu-plugins-chef* to your Gemfile and run `bundle install` or `bundle update`

#### Chef

Using the Sensu **sensu_gem** LWRP
```
sensu_gem 'sensu-plugins-chef' do
  options('--prerelease')
  version '0.0.1'
end
```

Using the Chef **gem_package** resource
```
gem_package 'sensu-plugins-chef' do
  options('--prerelease')
  version '0.0.1'
end
```

## Notes
