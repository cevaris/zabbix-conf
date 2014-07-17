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




def parse_ini
    # http://stackoverflow.com/questions/607640/how-to-read-an-ini-file-in-ruby
end


def execute(options={}, config={})
    puts "Executing #{options.inspect}"

    server = config[:server]
    client = config[:client]
    server_url = "http://#{server['ip']}/zabbix/api_jsonrpc.php"

    zbx = Timeout::timeout(TIMEOUT) {
      ZabbixApi.connect( 
        :url => server_url,
        :user => server['user'],
        :password => server['pass']
      )
    }

    hostgroup = Timeout::timeout(TIMEOUT) {
      zbx.hostgroups.get_or_create(:name => client['hostgroup'])
    }
  
end

def validate_inifile(client={}, server={})
  errors = []
  puts client.inspect
  puts server.inspect
  
  errors << 'Missing server dns' if server['dns'].nil?
  errors << 'Missing server ip'  if server['ip'].nil?
  errors << 'Missing server password'  if server['pass'].nil?
  errors << 'Missing server username'  if server['user'].nil?

  errors << 'Missing client dns' if client['dns'].nil?
  errors << 'Missing client ip'  if client['ip'].nil?

  return errors, {:client => client, :server => server}
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
    errors, args = validate_inifile(ini_data['client'],ini_data['server'])
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
