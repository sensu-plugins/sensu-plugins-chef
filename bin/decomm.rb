#!/usr/bin/env ruby
#
# This handler removes a Sensu client and disables Flapjack entity if its Chef node data
# no longer exists.
#
# Requires the following Rubygems (`gem install $GEM`):
#   - ridley
#   - flapjack-diner
#
# Requires a Sensu configuration snippet:
# Note: Sensu user has to be an owner of the file '/path/to/spocks/key.pem'
#       you can simply copy a key file to '/etc/sensu/ssl' and set appropriate ownership and permissions
#
#       chown sensu /etc/sensu/ssl/key.pem
#       chmod 400 /etc/sensu/ssl/key.pem
#
#   {
#     "decomm": {
#       "chef": {
#         "in_use": true,
#         "server_url": "https://api.opscode.com:443/organizations/foobar",
#         "client_name": "foo.example.com",
#         "client_key": "/etc/sensu/ssl/key.pem"
#       },
#       "flapjack": {
#         "in_use": true,
#         "server_url": "127.0.0.1:3081"
#       }
#     }
#   }
#
# Best to use this handler with a filter:
# Note: Only keepalive events with occurrences value greater than 10 will be handled by this handler
#       10 * 30s = 300s or 5min (30s represents keepalive check interval)
#
#   {
#     "filters": {
#       "keepalives": {
#         "attributes": {
#           "check": {
#             "name": "keepalive"
#           },
#           "occurrences": "eval: value > 10"
#         }
#       }
#     },
#     "handlers": {
#       "decomm": {
#         "type": "pipe",
#         "command": "decomm.rb",
#         "filter": "keepalives",
#         "timeout": 90
#       }
#     }
#   }
#
# Add decomm handler in the client configuration (e.g. client.rb)
#   {
#     "client": {
#       "name": "bar.example.com",
#       "address": "1.1.1.1",
#       "subscriptions": [
#         "base"
#       ],
#       "keepalive": {
#         "type": "metric",
#         "thresholds": {
#           "warning": 120,
#           "critical": 180
#         },
#         "handlers": [
#           "flapjack",
#           "decomm"
#         ],
#         "refresh": 60
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
require 'flapjack-diner'

class Decomm < Sensu::Handler
  def handler_name
    File.basename($PROGRAM_NAME, File.extname($PROGRAM_NAME))
  end

  def chef_node_exists?
    retried = 0
    begin
      Ridley::Logging.logger.level = Logger.const_get 'ERROR'

      Ridley.open(
        server_url: settings[handler_name]['chef']['server_url'],
        client_name: settings[handler_name]['chef']['client_name'],
        client_key: settings[handler_name]['chef']['client_key'],
        ssl: {
          verify: settings[handler_name]['chef']['client_key'].nil? ? true : settings[handler_name]['chef']['verify_ssl']
        }
      ) do |r|
        r.node.find(@event['client']['name']) ? true : false
      end
    # FIXME: Why is this necessary?  Ridley works fine outside of Sensu
    rescue Celluloid::Error
      Celluloid.boot
      retried += 1
      if retried < 2
        retry
      else
        puts "DECOMMISSION: Ridley is broken: #{error.inspect}"
        true
      end
    rescue => error
      puts "DECOMMISSION: Unexpected error: #{error.inspect}"
      true
    end
  end

  def disable_flapjack_entity!
    server_url = settings[handler_name]['flapjack']['server_url'].nil? ? '127.0.0.1:3081' : settings[handler_name]['flapjack']['server_url']

    Flapjack::Diner.base_uri(server_url)

    entity = @event['client']['name'].downcase

    Flapjack::Diner.entities_matching(/^#{entity}$/)[0][:links][:checks].each do |check|
      Flapjack::Diner.update_checks(check, enabled: false)
      puts "DECOMMISSION: Successfully disabled check #{check}"
    end
  end

  def delete_sensu_client!
    api_request(:DELETE, '/clients/' + @event['client']['name'])
    puts "DECOMMISSION: Successfully deleted Sensu client #{@event['client']['name']}"
  rescue => error
    puts "DECOMMISSION: Unexpected error: #{error.inspect}"
  end

  def filter; end

  def handle
    chef_in_use = settings[handler_name]['chef']['in_use'].nil? ? true : settings[handler_name]['chef']['in_use']

    chef_node_exists = if chef_in_use
                         chef_node_exists?
                       else
                         false
                       end

    if !chef_node_exists
      puts "DECOMMISSION: #{@event['check']['name']}: #{@event['check']['output']}, occurrences: #{@event['occurrences']}"
      puts "DECOMMISSION: Deleting sensu client #{@event['client']['name']}"
      delete_sensu_client!

      flapjack_in_use = settings[handler_name]['flapjack']['in_use'].nil? ? false : settings[handler_name]['flapjack']['in_use']

      if flapjack_in_use
        puts "DECOMMISSION: Disabling flapjack entity #{@event['client']['name']}"
        disable_flapjack_entity!
      end
    else
      puts "DECOMMISSION: #{@event['check']['name']}: #{@event['check']['output']}, occurrences: #{@event['occurrences']}"
      puts "DECOMMISSION: Node #{@event['client']['name']} object exists on Chef, nothing to do"
    end
  end
end
