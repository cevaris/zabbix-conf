#!/usr/bin/env ruby

require 'rubygems'
require "zabbixapi"

require "zabbix_conf/version"


HOST = 'zb00.cec.mltn.local'
URL  = "http://#{HOST}/zabbix/api_jsonrpc.php"

puts URL


$zbx = ZabbixApi.connect(
  :url => URL,
  :user => 'admin',
  :password => 'zabbix'
)


# Gets or Creates a Hostgroup
# Params:
# +name+:: hostname to be created and/or retrieved
def get_or_create_hostgroup( name )
    hostgroup = $zbx.hostgroups.get_id(:name => name)
    unless hostgroup
        hostgroup = $zbx.hostgroups.create(:name => name)
    end
    hostgroup
end

hostgroup_name = 'testGroup2'
puts get_or_create_hostgroup(hostgroup_name)

# test = zbx.hostgroups.get_id(:name => "hostgroup")
# puts test.inspect
# hostg = zbx.hostgroups.create(:name => 'testGroup')
# puts hostg.inspect

# module ZabbixConf
#   # Your code goes here...
# end
