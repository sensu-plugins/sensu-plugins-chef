#!/usr/bin/env ruby
# frozen_string_literal: false

#
# This handler removes a Sensu client if its Chef node data
# no longer exists.
#
# Requires the following Rubygems (`gem install $GEM`):
#   - ridley
#
# Requires a Sensu configuration snippet:
#   {
#     "chef": {
#       "server_url": "https://api.opscode.com:443/organizations/vulcan",
#       "client_name": "spock",
#       "client_key": "/path/to/spocks/key.pem"
#     }
#   }
#
# Best to use this handler with a filter:
#   {
#     "filters": {
#       "keepalives": {
#         "attributes": {
#           "check": {
#             "name": "keepalive"
#           }
#         }
#       }
#     },
#     "handlers": {
#       "chef_node": {
#         "type": "pipe",
#         "command": "chef_node.rb",
#         "filter": "keepalives"
#       }
#     }
#   }
#
# Copyright 2013 Heavy Water Operations, LLC.
#
# Released under the same terms as Sensu (the MIT license); see
# LICENSE for details.

require 'sensu-handler'
require 'ridley'

# supress the THOUSANDS of useless warnings
require 'hashie'
require 'hashie/logger'
Hashie.logger = Logger.new(nil)

#
# Chef Node
#
class ChefNode < Sensu::Handler
  def chef_node_exists?
    retried = 0
    begin
      Ridley.open(
        server_url: settings['chef']['server_url'],
        client_name: settings['chef']['client_name'],
        client_key: settings['chef']['client_key'],
        ssl: {
          verify: settings['chef']['client_key'].nil? ? true : settings['chef']['verify_ssl']
        }
      ) do |r|
        r.node.find(@event['client']['name']) ? true : false
      end
    # FIXME: Why is this necessary?  Ridley works fine outside of Sensu
    rescue Celluloid::Error => e
      Celluloid.boot
      retried += 1
      if retried < 2
        retry
      else
        puts "CHEF-NODE: Ridley is broken: #{e.inspect}"
        true
      end
    rescue StandardError => e
      puts "CHEF-NODE: Unexpected error: #{e.inspect}"
      true
    end
  end

  def delete_sensu_client!
    api_request(:DELETE, '/clients/' + @event['client']['name'])
    puts "CHEF-NODE: Successfully deleted Sensu client #{@event['client']['name']}"
  rescue StandardError => e
    puts "CHEF-NODE: Unexpected error: #{e.inspect}"
  end

  def filter; end

  def handle
    unless chef_node_exists? # rubocop:disable Style/GuardClause
      delete_sensu_client!
    end
  end
end
