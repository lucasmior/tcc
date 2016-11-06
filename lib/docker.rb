class LibDocker

  # Docker constructor.
  #
  # @param options [Hash]
  # @option ws_image [String]
  # @option lb_image [String]
  # @option lb_config_file [String] 
  #
  def initialize(options)

    fail('options parameter is not a hash') unless options.is_a?(Hash)
    #fail('Missing ws_image parameter') if ws_image.nil?
    #fail('Missing ws_port parameter') if ws_port.nil?
    #fail('Missing ws_limit parameter') if ws_limit.nil?
    #fail('Missing lb_image parameter') if lb_image.nil?
    #fail('Missing lb_config_file parameter') if lb_config_file.nil?
    @ws_image = options['ws_image']
    @ws_port = options['ws_port']
    @ws_limit = options['ws_limit'] || 4
    @lb_image = options['lb_image']
    @haproxy_config_file = options['lb_config_file']
    
    @hosts = options['hosts'] || ['0.0.0.0'] || ['15.29.219.177','15.29.219.21']
    
    @docker_port = 4243
    @container = []
  end

  def init
    puts 'Initializing the list of available servers'
    @hosts.each do |host|
      Docker.url = "tcp://#{host}:#{@docker_port}/"
      @container.concat(Docker::Container.all(all: true, filters: { ancestor: [@ws_image],status:['running'] }.to_json))
    end
  end

  ## Method to ...
  ##
  def threshold
    @hosts.each do |host|
      Docker.url = "tcp://#{host}:#{@docker_port}/"
      containers = Docker::Container.all(all: true, filters: { ancestor: [@ws_image],status:['running'] }.to_json)
      cpuPercent = 0.0

      status = containers.first.stats
      
      cpuDelta = status['cpu_stats']['cpu_usage']['total_usage'] - status['precpu_stats']['cpu_usage']['total_usage']
      systemDelta = status['cpu_stats']['system_cpu_usage'] - status['precpu_stats']['system_cpu_usage']

      if systemDelta > 0.0 and cpuDelta > 0.0 
          #puts "HERERE #{cpuDelta} #{systemDelta}"
          cpuPercent = (cpuDelta.round(16) / systemDelta.round(16)).round(16) * status['cpu_stats']['cpu_usage']['percpu_usage'].size * 100.0
      end
      return cpuPercent.round(2)
    end
  end

  ## Method to get the id and the server for an image in a pull of servers
  ##
  def get_container_id(image=@ws_image, hosts=@hosts)
    hosts.each do |host|
      Docker.url = "tcp://#{host}:#{@docker_port}/"
      containers = Docker::Container.all(all: true, filters: { ancestor: [image],status:['running'] }.to_json)
      return containers[0] unless containers.nil?
    end
    'nil'
  end

  ## Method to get the number of existing webservers running in a pull of servers
  ##
  def ws_running?(hosts=@hosts)
    #return @container.size
    total = 0

    hosts.each do |host|
      Docker.url = "tcp://#{host}:#{@docker_port}/"
      containers = Docker::Container.all(all: true, filters: { ancestor: [@ws_image], status:['running'] }.to_json)
      
      total += containers.size
    end
    total
  end

  ## Method to get an available port on a host
  ##
  def get_available_port(host)
    (7000..7010).each do |port|
       status = `nmap -p #{port} #{host} | grep #{port} | awk '{print $2}'`.chomp("\n")
       return port if status.eql? 'closed'
    end
    puts 'PUTA error. What should we do?'
    port = 8899
  end

  ## Method to ...
  ##
  def get_available_host
    ## get metrics from @hosts and returns the better
    #dont care with start or shutdown host, just use their from the list
    #todo
    @hosts.each do |host|
      return host if ws_running?([host]) < @ws_limit
    end
    puts 'FUCKING PROBLEM!'
    return 'localhost'
  end

  ## Method to create new containres based on available hosts and ports
  ##
  def create_new_container
    puts 'Start creating a new container..'
    host = get_available_host
    port = get_available_port(host)
    puts "using port #{port} from #{host}"

    Docker.url = "tcp://#{host}:#{@docker_port}/"
    container = Docker::Container.create(
        'Image' => "#{@ws_image}",
        'ExposedPorts' => { 
          '8070/tcp' => {}
        },
        'HostConfig' => {
          'CpuPeriod' => 25000,
          'Binds' => [
            '/home/mior/mior-github/tcc/haproxy/conf/:/etc/haproxy/'
          ],
          'PortBindings' => {
            '8070/tcp' => [ { 'HostPort' => "#{port}" } ]
          }
        }
      )
    container.start
    register_container(host, port, container.id)
  end

  ## Method to ...
  ##
  def kill_node
    puts 'Overload, let\'s kill a node..'
    return if ws_running? < 2
    to_kill = get_container_id(image=@ws_image)

    unregister_server(to_kill.id)
    container = Docker::Container.get(to_kill.id, to_kill.connection).kill
  end

  ## Method to register a new server on lb configurations
  ##
  def register_container(host, port, id)
    puts "Start registring container #{id}"
    name = 'webserver'
    tempfile = '/tmp/haproxy.cfg'
    server_config = "server #{name} #{host}:#{port} check \##{id}"
    
    contents = File.read(File.expand_path(@haproxy_config_file))

    open(tempfile, 'w+') do |f|
      contents.each_line do |line|
        
        f.puts line
        f.puts server_config if line.match('#BEGIN_SERVERS') and !contents.match(server_config)
      end
    end
    FileUtils.mv(tempfile, @haproxy_config_file)
  end

  ## Method to unregister a server on lb configurations
  ##
  def unregister_server(id)
    puts "Removing entry to #{id} from HA configurations"
    name = 'webserver'
    tempfile = '/tmp/haproxy.cfg'
    server_config = "server #{name}"
    
    contents = File.read(File.expand_path(@haproxy_config_file))

    open(tempfile, 'w+') do |f|
      contents.each_line do |line|
        f.puts line unless line.match(id)
      end
    end
    FileUtils.mv(tempfile, @haproxy_config_file)

  end

  def lb_running?
    containers = Docker::Container.all(all: true, filters: { ancestor: [@lb_image], status:['running'] }.to_json)
    if containers.empty? 
      lb = Docker::Container.create(
        'Cmd'=> [
          '-n',
          '10000'
        ],
        'Image' => "#{@lb_image}",
        'ExposedPorts' => { 
          "443/tcp"=> {},
          "80/tcp"=> {},
          "8888/tcp"=> {}
        },
        'HostConfig' => {
          "Binds"=> [
            "/home/mior/mior-github/tcc/haproxy/conf/:/etc/haproxy/"
          ],
          'PortBindings' => {
            '80/tcp' => [{ 'HostPort' => '80' }],
            '8888/tcp' => [{ 'HostPort' => '8888' }]
          }
        }
      )
      lb.start
      puts 'Load Balancer lunched!'
    end
  end

  def clean_up
    name = 'webserver'
    tempfile = '/tmp/haproxy.cfg'
    server_config = "server #{name}"
    
    contents = File.read(File.expand_path(@haproxy_config_file))

    open(tempfile, 'w+') do |f|
      contents.each_line do |line|
        f.puts line unless line.match(server_config)
      end
    end
    FileUtils.mv(tempfile, @haproxy_config_file)
  end

  def update_lb_servers
    clean_up
    @hosts.each do |host|
      Docker.url = "tcp://#{host}:#{@docker_port}/"
      containers = Docker::Container.all(all: true, filters: { ancestor: [@ws_image], status:['running'] }.to_json)
      containers.each do |container|
        port = container.json['HostConfig']['PortBindings']['8070/tcp'][0]['HostPort']
        register_container(host, port, container.id)
      end
    end
  end

end