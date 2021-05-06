#! /usr/bin/env ruby
# frozen_string_literal: true

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
require 'ridley'

# supress the THOUSANDS of useless warnings
require 'hashie'
require 'hashie/logger'
Hashie.logger = Logger.new(nil)

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

  option :grace_period,
         description: 'The amount of time before a node should be evaluated for failed convergence',
         long: '--grace-period SECONDS',
         # default 5 minutes, which seems like a good but not great default
         default: (60 * 5),
         proc: proc(&:to_i)

  option :ignore_ssl_verification,
         description: 'Ignore SSL certificate verification',
         short: '-i',
         long: '--ignore-ssl',
         default: false,
         boolean: true

  def connection
    @connection ||= chef_api_connection
  end

  def nodes_last_seen
    nodes = connection.node.all
    nodes.delete_if { |node| node.name =~ /#{config[:exclude_nodes]}/ }

    checked_nodes = []
    nodes.each do |node|
      node.reload
      # no uptime: node might have not finished convergence -> won't check
      unless node['automatic']['uptime_seconds']
        checked_nodes << { node['name'] => false }
        next
      end

      # won't check if node's uptime is still within grace period
      unless node['automatic']['uptime_seconds'] > config[:grace_period]
        checked_nodes << { node['name'] => false }
        next
      end

      # compute elapsed time since last convergence
      checked_nodes << if node['automatic']['ohai_time']
                         { node['name'] => (Time.now - Time.at(node['automatic']['ohai_time'])) > config[:critical_timespan].to_i }
                       else
                         { node['name'] => true }
                       end
    end
    checked_nodes
  end

  def run
    if any_node_stuck?
      critical "The following nodes cannot be provisioned: #{failed_nodes_names}"
    else
      ok 'Chef Server API is ok, all nodes reporting'
    end
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

  def any_node_stuck?
    stuck = []
    @nodes_last_seen ||= nodes_last_seen
    @nodes_last_seen.flatten.each do |node|
      node.each do |name, status|
        stuck << name if status == true
      end
    end
    if stuck.empty?
      false
    else
      true
    end
  end

  def failed_nodes_names
    failed_nodes = []
    @nodes_last_seen.flatten.each do |node|
      node.each do |name, status|
        failed_nodes << name if status == true
      end
    end
    failed_nodes
  end
end
