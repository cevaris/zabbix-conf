#!/usr/bin/env ruby

require 'rubygems'
require "zabbixapi"

require "zabbix_conf/version"

# sync global stdout
STDOUT.sync = true


HOST = 'zb00.cec.mltn.local'
URL  = "http://#{HOST}/zabbix/api_jsonrpc.php"
print "Connecting to #{URL}"
$zbx = ZabbixApi.connect(
  :url => URL,
  :user => 'admin',
  :password => 'zabbix'
)
puts "...connected"

hostgroup_name = 'testGroup'
puts $zbx.hostgroups.get_or_create(:name => hostgroup_name)


# module ZabbixConf
#   # Your code goes here...
# end
