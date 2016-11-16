require 'tempfile'
require 'fileutils'
require 'net/http'
require 'rubygems'
require 'json'
require 'docker'

host = 'localhost'
port = 4243
lb_image = 'million12/haproxy'
ws_image = 'lucasmior/cesar_ws:0.2'

input="{
    \"Reservations\" => [{
        \"Instances\" => [{
            \"InstanceType\" => \"t2.medium\",
            \"AmiLaunchIndex\" => 0,
            \"Monitoring\" => {
                \"State\" => \"disabled\"
            },
            \"RootDeviceName\" => \"/dev/sda1\",
            \"BlockDeviceMappings\" => [{
                \"DeviceName\" => \"/dev/sda1\",
                \"Ebs\" => {
                    \"Status\" => \"attaching\", \"AttachTime\" => \"2016-11-15T05:44:49.000Z\", \"DeleteOnTermination\" => true, \"VolumeId\" => \"vol-5d2c3bf3\"
                }
            }],
            \"NetworkInterfaces\" => [{
                \"Description\" => nil,
                \"Groups\" => [{
                    \"GroupId\" => \"sg-5bb3af3f\",
                    \"GroupName\" => \"mior-sg\"
                }],
                \"NetworkInterfaceId\" => \"eni-8ff1f6a4\",
                \"SourceDestCheck\" => true,
                \"OwnerId\" => \"957591566260\",
                \"VpcId\" => \"vpc-24061c46\",
                \"PrivateIpAddresses\" => [{
                    \"Association\" => {
                        \"PublicDnsName\" => \"ec2-54-183-232-65.us-west-1.compute.amazonaws.com\", \"IpOwnerId\" => \"amazon\", \"PublicIp\" => \"54.183.232.65\"
                    },
                    \"PrivateIpAddress\" => \"172.31.19.66\",
                    \"Primary\" => true,
                    \"PrivateDnsName\" => \"ip-172-31-19-66.us-west-1.compute.internal\"
                }],
                \"PrivateDnsName\" => \"ip-172-31-19-66.us-west-1.compute.internal\",
                \"Attachment\" => {
                    \"Status\" => \"attaching\", \"AttachTime\" => \"2016-11-15T05:44:49.000Z\", \"DeleteOnTermination\" => true, \"DeviceIndex\" => 0, \"AttachmentId\" => \"eni-attach-3c2cef6d\"
                },
                \"PrivateIpAddress\" => \"172.31.19.66\",
                \"SubnetId\" => \"subnet-af9976ca\",
                \"Status\" => \"in-use\",
                \"Association\" => {
                    \"PublicDnsName\" => \"ec2-54-183-232-65.us-west-1.compute.amazonaws.com\", \"IpOwnerId\" => \"amazon\", \"PublicIp\" => \"54.183.232.65\"
                }
            }],
            \"VpcId\" => \"vpc-24061c46\",
            \"PrivateDnsName\" => \"ip-172-31-19-66.us-west-1.compute.internal\",
            \"Placement\" => {
                \"AvailabilityZone\" => \"us-west-1c\", \"GroupName\" => nil, \"Tenancy\" => \"default\"
            },
            \"SubnetId\" => \"subnet-af9976ca\",
            \"ProductCodes\" => [],
            \"VirtualizationType\" => \"hvm\",
            \"PublicIpAddress\" => \"54.183.232.65\",
            \"ClientToken\" => nil,
            \"SecurityGroups\" => [{
                \"GroupId\" => \"sg-5bb3af3f\",
                \"GroupName\" => \"mior-sg\"
            }],
            \"State\" => {
                \"Code\" => 0, \"Name\" => \"pending\"
            },
            \"SourceDestCheck\" => true,
            \"StateTransitionReason\" => nil,
            \"LaunchTime\" => \"2016-11-15T05:44:49.000Z\",
            \"RootDeviceType\" => \"ebs\",
            \"Hypervisor\" => \"xen\",
            \"ImageId\" => \"ami-999ecbf9\",
            \"Architecture\" => \"x86_64\",
            \"KeyName\" => \"mior\",
            \"PublicDnsName\" => \"ec2-54-183-232-65.us-west-1.compute.amazonaws.com\",
            \"InstanceId\" => \"i-815fffde\",
            \"PrivateIpAddress\" => \"172.31.19.66\",
            \"EbsOptimized\" => false
        }],
        \"OwnerId\" => \"957591566260\",
        \"ReservationId\" => \"r-86e20845\",
        \"Groups\" => []
    }]
}"

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

def home
  lb_image = 'million12/haproxy'
  containers = Docker::Container.all(all: true, filters: { ancestor: [lb_image], status:['running'] }.to_json)
  puts 'c'
  puts containers
  if containers.empty? 
    puts 'nil'
  end
  ws_image = 'lucasmior/cesar_ws:0.1'
  port = 7001
  host = 'localhost'
  docker_port = 4243
  Docker.url = "tcp://#{host}:#{docker_port}/"
    #container = Docker::Container.create(json)
  puts 'here'
  container = Docker::Container.all
  c = []
  c.concat(container)
  puts c
  c.delete(c.first)
  puts ''
  puts c
end

  #puts time = Time.now.to_f
#register_container(host,port)
#c = filter
#remove(c)
#Docker.url = "tcp://15.29.219.21:4243"
#Docker.url = "tcp://52.15.59.150:4243"
##containers = Docker::Container.all(all: true, filters: { ancestor: [ws_image], status:['running'] }.to_json)
#puts containers
#containers.each do |c| puts c.stats end
#puts home 
json = JSON.parse(input)
puts json["Reservations"][0]["Instances"][0]["NetworkInterfaces"][0]["PrivateIpAddress"]
puts json["Reservations"][0]["Instances"][0]["NetworkInterfaces"][0]["Association"]["PublicIp"]