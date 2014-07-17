module ZabbixConf
  class Configure
    def zab_client(config={})
      server     = config[:server]
      agent      = config[:agent]
      server_url = "http://#{server['ip']}/zabbix/api_jsonrpc.php"

      Timeout::timeout(TIMEOUT) {
        ZabbixApi.connect( 
          :url      => server_url,
          :user     => server['user'],
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
          :hosts_id     => [client.hosts.get_id(:host => agent['fqdn'])],
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
      
      puts 'Done configuring agent'
    end
  end
end
