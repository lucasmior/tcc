# tcc
## Author: Lucas Mior


servers::
1. ssh-keygen -t rsa
Press enter for each line 
2. cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
3. chmod og-wx ~/.ssh/authorized_keys 
http://stackoverflow.com/questions/7439563/how-to-ssh-to-localhost-without-password
sudo apt-get install  nmap
nmap -p 8444 localhost

How to run:
```ruby
ruby loadbalancer.rb
```
https://www.linux.com/news/getting-started-docker
Needed:
gem install docker-api

docker run -p 8070:8070 --cpu-period=250000 --cpu-quota=10000 -v /home/mior/mior-github/tcc/python/app:/app -d --name flask_ws flask_2
curl -X POST -d '{"cifra":"abcdefghijk","order":"5" }' 15.29.219.177/cesar
docker run -d -p 80:80 -p 8888:8888 -v ~/mior-github/tcc/haproxy/conf/:/etc/haproxy/ million12/haproxy -n 10000
docker run -p 8077:8070 --cpu-period=25000 -d lucasmior/cesar_ws:0.1
fghijklmnopcurl -X POST -d '{code:abcdefghijk,key:5 }' localhost/cesar
