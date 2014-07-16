# zabbix-conf
===========

## File based configuration for Zabbix

#### Example configuration file
```
[host]
ip=192.168.10.60
dns=server.hostname.example.com

[client]
dns=client.hostname.example.com
ip=192.168.10.60
port=10050
useip=0
hostgroup=testGroup
```

#### Upload configuration
```
zabconf /path/to/config/file
....
```