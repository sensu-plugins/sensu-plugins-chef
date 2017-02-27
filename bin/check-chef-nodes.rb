#! /usr/bin/env ruby
#
#   check-chef-nodes
#
# DESCRIPTION:
#   It will report you nodes from you cluster last seen more then some amount of seconds
#   Set CRITICAL-TIMESPAN to something interval + splay + <average chef kitchen run time>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.#
#
# OUTPUT:
#   <output> plain text, metric data, etc
#
# PLATFORMS:
#   Linux, Windows, BSD, Solaris, etc
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: <?>
#
# USAGE:
#   Look for nodes that haven't check in for 1 or more hours
#   ./check-chef-nodes.rb -t 3600 -U https://api.opscode.com/organizations/<org> -K /path/to/org.pem
#   ./check-chef-nodes.rb -t 3600 -U https://api.opscode.com/organizations/<org> -K /path/to/org.pem -e "^sensu.*$"
#
# NOTES:
#
# LICENSE:
#   Copyright 2014 Sonian, Inc. and contributors. <support@sensuapp.org>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'chef'

#
# Chef Nodes Status Checker
#
class ChefNodesStatusChecker < Sensu::Plugin::Check::CLI
  option :critical_timespan,
         description: 'Amount of seconds after which node considered as stuck',
         short: '-t CRITICAL-TIMESPAN',
         long: '--timespan CRITICAL-TIMESPAN',
         default: (1800 + 300.0 + 180)

  option :chef_server_url,
         description: 'URL of Chef server',
         short: '-U CHEF-SERVER-URL',
         long: '--url CHEF-SERVER-URL'

  # defaults to the equivalent of `hostname --fqdn`
  option :client_name,
         description: 'Client name',
         short: '-C CLIENT-NAME',
         long: '--client CLIENT-NAME',
         required: true,
         default: Socket.gethostbyname(Socket.gethostname).first

  option :key,
         description: 'Client\'s key',
         short: '-K CLIENT-KEY',
         long: '--keys CLIENT-KEY'

  option :exclude_nodes,
         description: 'Node to excludes',
         short: '-e EXCLUDE-NODES',
         long: '--exclude-nodes EXCLUDE-NODES',
         default: '^$'

  def connection
    @connection ||= chef_api_connection
  end

  def nodes_last_seen
    nodes = connection.get_rest('/nodes')
    nodes.delete_if { |node_name| node_name =~ /#{config[:exclude_nodes]}/ }
    nodes.keys.map do |node_name|
      node = connection.get_rest("/nodes/#{node_name}")
      if node['automatic']['ohai_time']
        { node_name => (Time.now - Time.at(node['automatic']['ohai_time'])) > config[:critical_timespan].to_i }
      else
        { node_name => true }
      end
    end
  end

  def run
    if any_node_stuck?
      ok 'Chef Server API is ok, all nodes reporting'
    else
      critical "The following nodes have not reported within #{config[:critical_timespan]} seconds: #{failed_nodes_names}"
    end
  end

  private

  def chef_api_connection
    options[:client_name] = config[:client_name]
    options[:signing_key_filename] = config[:key]
    options[:inflate_json_class] = false
    chef_server_url = config[:chef_server_url]
    Chef::ServerAPI.new(chef_server_url, options)
  end

  def any_node_stuck?
    @nodes_last_seen ||= nodes_last_seen
    @nodes_last_seen.map(&:values).flatten.all? { |x| x == false }
  end

  def failed_nodes_names
    all_failed_tuples = @nodes_last_seen.select { |node_set| node_set.values.first == true }
    all_failed_tuples.map(&:keys).flatten.join(', ')
  end
end
