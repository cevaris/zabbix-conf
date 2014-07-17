#!/usr/bin/env ruby

require 'rubygems'
require 'inifile'
require 'zabbixapi'
require 'timeout'
require 'optparse'

require "zabbix_conf/version"

# sync global stdout
STDOUT.sync = true

TIMEOUT = 10

TYPE_AGENT = 1
TYPE_SNMP  = 2
TYPE_IPMI  = 3
TYPE_JMX   = 4

YES = 1
NO  = 0

AGENT_PORT = 10050

TEMPLATE_LINUX = 10001


def zab_client(config={})
  server     = config[:server]
  agent      = config[:agent]
  server_url = "http://#{server['ip']}/zabbix/api_jsonrpc.php"

  Timeout::timeout(TIMEOUT) {
    ZabbixApi.connect( 
      :url => server_url,
      :user => server['user'],
      :password => server['pass']
    )
  }
end

def get_template(client, config={})
  server = config[:server]
  agent  = config[:agent]

  Timeout::timeout(TIMEOUT) {
    client.templates.get_id(:host => agent['template'])
  }
end

def create_hostgroup(client, config={})
  server = config[:server]
  agent  = config[:agent]
  
  Timeout::timeout(TIMEOUT) {
    client.hostgroups.get_or_create(:name => agent['hostgroup'])
  }
end

def add_tempalte_to_host(client, config={})
  server = config[:server]
  agent  = config[:agent]

  template_ids = [get_template(client, config)]

  Timeout::timeout(TIMEOUT) {
    client.templates.mass_add(
      :hosts_id => [client.hosts.get_id(:host => agent['fqdn'])],
      :templates_id => template_ids
    )
  }
end

def create_host(client, config={})
  server = config[:server]
  agent  = config[:agent]

  hostgroup = create_hostgroup(client, config)

  Timeout::timeout(TIMEOUT) {
    client.hosts.create_or_update(
      :host => agent['fqdn'],
      :interfaces => [{
        :type  => TYPE_AGENT,
        :main  => YES,
        :ip    => agent['ip'],
        :dns   => agent['fqdn'],
        :port  => AGENT_PORT,
        :useip => YES 
      }],
      :groups => [:groupid => hostgroup]
    )
  }
end


def config_server(options={}, config={})
  server = config[:server]
  agent  = config[:agent]

end

def config_agent(options={}, config={})
  server = config[:server]
  agent = config[:agent]

  zbx = zab_client(config)
  host = create_host(zbx, config)
  add_tempalte_to_host(zbx, config)
  
  puts host.inspect
end


def execute(options={}, config={})
    server = config[:server]
    agent  = config[:agent]

    if !agent.empty? && !server.empty?
      config_agent(options, config)
    end
    
    if server
      config_server(options, config)
    end

end

def validate_inifile(agent={}, server={})
  errors = []
  
  unless server.empty?
    errors << 'Missing server fqdn' if server['fqdn'].nil?
    errors << 'Missing server ip'   if server['ip'].nil?
    errors << 'Missing server password'  if server['pass'].nil?
    errors << 'Missing server username'  if server['user'].nil?
  end
  unless agent.empty?
    errors << 'Missing agent fqdn' if agent['fqdn'].nil?
    errors << 'Missing agent ip'   if agent['ip'].nil?
  end
  
  return errors, {:agent => agent, :server => server}
end


def validate_args(optparse, options)
  begin
    optparse.parse!
    required = [:config_path]
    missing = required.select{ |param| options[param].nil? }
    if not missing.empty?
      puts "Missing options: #{missing.join(', ')}"
      puts optparse
      exit
    end

    # Check if config exists, else throw error
    raise Errno::ENOENT.new options[:config_path] unless File.exists?(options[:config_path]) 

    # Validate ini file
    ini_data = IniFile.load(options[:config_path])
    errors, args = validate_inifile(ini_data['agent'],ini_data['server'])
    raise "Configuration Error\n #{errors.join("\n")}" unless errors.empty?

    # All is valid, return arguments
    args
  rescue OptionParser::InvalidOption, OptionParser::MissingArgument
    puts $!.to_s
    puts optparse
    exit
  end
end


if __FILE__ == $0

  options = {}

  optparse = OptionParser.new do|opts|
    opts.banner = "Usage: zabconf [options] --config-path=FILE"

    options[:verbose] = false
      opts.on( '-v', '--verbose', 'Output more information' ) do
      options[:verbose] = true
    end

    opts.on( '-c', '--config-path FILE', 'Path to config file' ) do |value|
      options[:config_path] = value
    end

    opts.on( '-h', '--help', 'Display this screen' ) do
      puts opts
      exit
    end
  end

  # Execute script if valid args
  config = validate_args(optparse, options)   
  execute(options, config) if config 
  
end


# module ZabbixConf
#   # Your code goes here...
# end
