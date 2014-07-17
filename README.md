# zabbix-conf
===========

## File based configuration for Zabbix

#### Example configuration file
```
[server]
ip   = 192.168.10.50
fqdn = server.hostname.example.com
pass = zabbix
user = admin

[client]
fqdn      = client.hostname.example.com
ip        = 192.168.10.60
hostgroup = testGroup
```

#### Execute configuration
```
/usr/local/bin/zabconf /etc/zabbix/zabcon.ini
```