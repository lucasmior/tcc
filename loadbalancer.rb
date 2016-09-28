## Author: Lucas Mior

def estimate_servers do
  1
end

IMAGE='webserver_tcc' #it should be builded on machine or available on docker registry
KEEP=5 #calculate that via requests reveived

# list of servers available. Use more if needed and turn off when idle
servers = ['localhost']

#thread 1 add request
#1 round robin between servers
#2 fill an entire server after fill the second one

#thread 2 manage resources

while 1
  estimate_servers 
  servers.each do |s|
    ws  = `ssh #{s} "docker ps | grep #{IMAGE} | wc -l"`.to_i
    until ws == KEEP
      if ws < KEEP 
        `ssh #{s} docker run -td webserver_tcc`
        sleep 2 
        ws = `ssh #{s} "docker ps | grep #{IMAGE} | wc -l"`.to_i
        puts "increased #{ws}"
      elsif ws > KEEP
        `ssh #{s} "docker rm -f $(docker ps | grep #{IMAGE} | head -n 1 | awk '{print $1}')"`
        sleep 2 
        ws = `ssh #{s} "docker ps | grep #{IMAGE} | wc -l"`.to_i
        puts "decreased #{ws}"
      end
    end
    puts 'next ws' 
  end
  puts 'waiting 10 second to polling'
  sleep 10
end
#A=$(nmap -p 8006 localhost | grep /tcp | awk '{print $2}')

