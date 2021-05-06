#! /usr/bin/env ruby
# frozen_string_literal: true

#   check-chef-node
#
# DESCRIPTION:
#   Check if a node exists.
#
# OUTPUT:
#   <output> plain text, metric data, etc
#
# PLATFORMS:
#   Linux, Windows, BSD, Solaris, etc
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: chef
#
# USAGE:
#   ./check-chef-node.rb -U https://api.opscode.com/organizations/<org> -K /path/to/org.pem -n mynode
#
# NOTES:
#
# LICENSE:
#   Copyright (c) 2015, Olivier Bazoud, olivier.bazoud@gmail.com
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'ridley'

# supress the THOUSANDS of useless warnings
require 'hashie'
require 'hashie/logger'
Hashie.logger = Logger.new(nil)

class ChefNodeChecker < Sensu::Plugin::Check::CLI
  option :node_name,
         description: 'Check if this node name exists',
         short: '-n NODE-NAME',
         long: '--node-name NODE-NAME'

  option :chef_server_url,
         description: 'URL of Chef server',
         short: '-U CHEF-SERVER-URL',
         long: '--url CHEF-SERVER-URL'

  option :client_name,
         description: 'Client name',
         short: '-C CLIENT-NAME',
         long: '--client CLIENT-NAME'

  option :key,
         description: 'Client\'s key',
         short: '-K CLIENT-KEY',
         long: '--keys CLIENT-KEY'

  option :ignore_ssl_verification,
         description: 'Ignore SSL certificate verification',
         short: '-i',
         long: '--ignore-ssl'

  def connection
    @connection ||= chef_api_connection
  end

  def run
    node = connection.node.find(config[:node_name])
    if node['automatic']['ohai_time']
      ok "Node #{config[:node_name]} found"
    else
      warning "Node #{config[:node_name]} does not contain 'ohai_time' attribute"
    end
  rescue StandardError => e
    critical "Node #{config[:node_name]} not found - #{e.message}"
  end

  private

  def chef_api_connection
    chef_server_url      = config[:chef_server_url]
    client_name          = config[:client_name]
    signing_key_filename = config[:key]
    ignore_ssl = config[:ignore_ssl_verification]
    verify_ssl = ignore_ssl.nil?

    Celluloid.boot
    Ridley.new(server_url: chef_server_url, client_name: client_name, client_key: signing_key_filename, ssl: { verify: verify_ssl })
  end
end
