require 'docker-api'
require_relative 'lib/docker'

# Define the thresholds that will be used to scale the system
threshold = 15
threshold_min = 8
cpu_usage = 0

# Define the options to initialize the lib docker 
options = {}
options['ws_image'] = 'lucasmior/cesar_ws:0.2'
options['ws_port'] = 8070
options['lb_image'] = 'million12/haproxy'
options['lb_config_file'] = '/home/mior/mior-github/tcc/haproxy/conf/haproxy.cfg'
options['hosts'] = ['15.29.219.177']

# Initialize lib docker object
docker = LibDocker.new(options)

# Verify if there is a loab balancer already running
docker.lb_running?

# Get the number of webservers that already are running
running = docker.ws_running?

# Create a new one if there is no webserver running
docker.create_new_container if running < 1

# Update the load balancer's configuration file to add the running webservers
docker.update_lb_servers

puts "Initial number of webservers: #{running}"

while 1 do
  # Get current cpu usage from a running webserver
  cpu_usage = docker.cpu_usage
  # Get the amount of webservers running
  running = docker.ws_running?

  puts "Current cpu usage is: #{cpu_usage} and there are #{running} webservers running"

  # Decide if is needed create a new webserver if the cpu_usage is more than threashold or
  # kill a webserver if the cpu_usage is less than threshold
  if cpu_usage > threshold
    docker.create_new_container
  elsif cpu_usage < threshold_min and running > 1
    docker.kill_node
  end
end
