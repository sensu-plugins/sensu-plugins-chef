#! /usr/bin/env ruby
#
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
require 'chef'

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

  def connection
    @connection ||= chef_api_connection
  end

  def run
    node = connection.get_rest("/nodes/#{config[:node_name]}")
    if node['automatic']['ohai_time']
      ok "Node #{config[:node_name]} found"
    else
      warning "Node #{config[:node_name]} does not contain 'ohai_time' attribute"
    end
  rescue => e
    critical "Node #{config[:node_name]} not found - #{e.message}"
  end

  private

  def chef_api_connection
    options[:client_name] = config[:client_name]
    options[:signing_key_filename] = config[:key]
    options[:inflate_json_class] = false
    chef_server_url = config[:chef_server_url]
    Chef::ServerAPI.new(chef_server_url, options)
  end
end
