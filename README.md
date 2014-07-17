# zabbix-conf
===========

## File based configuration for Zabbix

#### Example configuration file
```
[server]
fqdn = server.example.com
ip   = 192.168.10.50
pass = zabbix
user = admin

[agent]
fqdn      = agent.example.com
ip        = 192.168.10.60
hostgroup = localGroup
template  = Template OS Linux
```

#### Execute Agent configuration
```
zabconf -c /etc/zabbix/agent.ini
```