#!/bin/bash
docker run -d -p 80:80 -p 8888:8888 -v ~/mior-github/tcc/haproxy/conf/:/etc/haproxy/ million12/haproxy -n 10000
