require 'tempfile'
require 'fileutils'
require 'net/http'
require 'rubygems'
require 'json'
require 'docker'

host = 'localhost'
port = 4243
lb_image = 'million12/haproxy'
ws_image = 'lucasmior/cesar_ws:0.1'


def puts_port
  # Request all of the Containers, filtering by status exited.
  containers = Docker::Container.all(all: true)
  containers.each do |container|
    puts 'image: ' + container.json['Config']['Image']
    if container.json['Config']['Image'] == ws_image
      puts 'here!!'
      port = container.json['HostConfig']['PortBindings']['8070/tcp'][0]['HostPort']
      puts port
    end 
  end
end

def filter
  #puts filters: { ancestor: ["lucasmior"] }
  ws_image = 'lucasmior/cesar_ws:0.1'
  #Docker.url = "tcp://15.29.219.21:4243/"
  c = Docker::Container.all(all: true, filters: { ancestor: [ws_image] }.to_json)
  puts c
  c
end

def remove(c)
  #Docker.url = c.connection.url

  c = Docker::Container.get(c.id, c.connection)
  c.stop
end


def register_container(host, port)
  lb_image = 'million12/haproxy'
  ws_image = 'lucasmior/cesar_ws:0.1'
  haproxy_config_file = '/home/mior/mior-github/tcc/haproxy/conf/haproxy.cfg'


  puts 'Start registring container'
  # TODO Its returning the same name. Remove get_next name and get_last_server if dont change the name
  #name = "#{get_next_name}"
  name = 'webserver'
  tempfile = '/tmp/haproxy.cfg'
  server_config = "server\ #{name}\ #{host}:#{port}\ check"
  
  contents = File.read(File.expand_path(haproxy_config_file))

  open(tempfile, 'w+') do |f|
    contents.each_line do |line|
      
      f.puts line
      f.puts server_config if line.match('#BEGIN_SERVERS') and !contents.match(server_config)
    end
  end
  FileUtils.mv(tempfile, haproxy_config_file)





#{}`sed -i "/#END_SERVERS/i server\ #{name}\ #{host}:#{port}\ check" #{@haproxy_config_file}`
end

def test
  ws_image = 'lucasmior/cesar_ws:0.1'
  Docker.url = "tcp://15.29.219.21:4243/"
  puts 'first'
  conts = Docker::Container.all(all: true, filters: { ancestor: [ws_image],status:['running'] }.to_json)
  puts conts
end


#register_container(host,port)
#c = filter
#remove(c)

puts test