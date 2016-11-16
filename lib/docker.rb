class LibDocker
  ## Docker constructor.
  ##
  ## @param options [Hash]
  ## @option ws_image [String] - Required
  ## @option ws_port [Int] - Required
  ## @option ws_limit [Int] - Optional
  ## @option lb_image [String] - Required
  ## @option lb_config_file [String] - Required
  ## @option hosts [Array] - Optional
  ##
  def initialize(options)
    fail('options parameter is not a hash') unless options.is_a?(Hash)
    fail('Missing ws_image parameter') if options['ws_image'].nil?
    fail('Missing ws_port parameter') if options['ws_port'].nil?
    fail('Missing lb_image parameter') if options['lb_image'].nil?
    fail('Missing lb_config_file parameter') if options['lb_config_file'].nil?
    @ws_image = options['ws_image']
    @ws_port = options['ws_port']
    @ws_limit = options['ws_limit'] || 4
    @lb_image = options['lb_image']
    @haproxy_config_file = options['lb_config_file']
    
    @hosts = options['hosts'] || ['127.0.0.1']
    
    @docker_port = 4243
  end

  ## Method to get the cpu usage from a running webserver
  ##
  def cpu_usage
    containers = []
    @hosts.each do |host|
      Docker.url = "tcp://#{host}:#{@docker_port}/"
      containers.concat Docker::Container.all(all: true, filters: { ancestor: [@ws_image],status:['running'] }.to_json)
    end
    
    cpuPercent = 0.0
    status = containers.first.stats
    
    cpuDelta = status['cpu_stats']['cpu_usage']['total_usage'] - status['precpu_stats']['cpu_usage']['total_usage']
    systemDelta = status['cpu_stats']['system_cpu_usage'] - status['precpu_stats']['system_cpu_usage']

    if systemDelta > 0.0 and cpuDelta > 0.0 
      cpuPercent = (cpuDelta.round(16) / systemDelta.round(16)).round(16) * status['cpu_stats']['cpu_usage']['percpu_usage'].size * 100.0
    end
    return cpuPercent.round(2)
  end

  ## Method to get the id and the server for an image in a pull of servers
  ##
  def get_container_id(image=@ws_image, hosts=@hosts)
    hosts.each do |host|
      Docker.url = "tcp://#{host}:#{@docker_port}/"
      containers = Docker::Container.all(all: true, filters: { ancestor: [image],status:['running'] }.to_json)
      return containers.first unless containers.empty?
    end
    fail('Could not found a webserver running')
  end

  ## Method to get the number of existing webservers running in a pull of servers
  ##
  def ws_running?(hosts=@hosts)
    total = 0
    puts "looking at: #{@hosts}"
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
    (7000..7100).each do |port|
      status = `nmap -Pn -p #{port} #{host} | grep #{port} | awk '{print $2}'`.chomp("\n")
      return port if status.eql? 'closed'
    end
    nil
  end

  ## Method to get an available host to instantiate new containers
  ##
  def get_available_host
    @hosts.each do |host|
      return host if ws_running?([host]) < @ws_limit
    end
    puts "No host available! Providing a new one on aws"
    json = `aws ec2 run-instances --image-id ami-689cc908 --instance-type t2.medium --key-name mior --security-group-id sg-5bb3af3f`
    json = JSON.parse(json)
    internal_ip = json["Instances"][0]["NetworkInterfaces"][0]["PrivateIpAddress"]
    public_ip = nil
    while public_ip.nil?
      cmd = "aws ec2 describe-instances --filter \"Name=private-ip-address, Values=#{internal_ip}\""
      json = JSON.parse(`#{cmd}`)
      public_ip = json["Reservations"][0]["Instances"][0]["NetworkInterfaces"][0]["Association"]["PublicIp"]
    end
    puts "New instance on aws: #{public_ip}"
    @hosts.push(public_ip)
    puts 'Waiting the host powers up..'
    sleep 30
    public_ip
    # The elegant way should be instantiate a new host to receive more requests
  end

  ## Method to create new containers based on available hosts and ports
  ##
  def create_new_container
    puts 'Start creating a new container..'
    host = get_available_host
    if host.nil?
      puts 'Could not found a host with limit enough to create more containers'
      return
    end
    puts "getting an available port to #{host}"
    port = get_available_port(host)
    if port.nil?
      puts 'Could not found an available port'
      return
    end

    puts "using port #{port} from #{host}"

    Docker.url = "tcp://#{host}:#{@docker_port}/"
    container = Docker::Container.create(
        'Image' => "#{@ws_image}",
        'ExposedPorts' => { 
          '8070/tcp' => {}
        },
        'HostConfig' => {
          'CpuPeriod' => 25000,
          'PortBindings' => {
            '8070/tcp' => [ { 'HostPort' => "#{port}" } ]
          }
        }
      )
    container.start
    register_container(host, port, container.id)
  end

  ## Method to terminate a node when there is overload
  ##
  def kill_node
    return if ws_running? < 2
    puts 'Low load, let\'s kill a node..'
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

  # Method to run a new HAProxy load balancer when there is no lb running
  #
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

  # Method to clean up the webservers entries on HAProxy lb configuration file
  #
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
  
  # Method to update the webservers entries with the running webservers
  #
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