#!/usr/bin/env ruby

require 'rubygems'
require "zabbixapi"

require "zabbix_conf/version"


HOST = 'zb00.cec.mltn.local'
URL  = "http://#{HOST}/zabbix/api_jsonrpc.php"

puts URL

zbx = ZabbixApi.connect(
  :url => URL,
  :user => 'admin',
  :password => 'zabbix'
)
puts zbx.inspect

# module ZabbixConf
#   # Your code goes here...
# end
