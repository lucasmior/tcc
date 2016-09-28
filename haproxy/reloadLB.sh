#!/bin/bash

docker exec haproxy_hp_26-09 haproxy -f /usr/local/etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid -sf $(</var/run/haproxy.pid)

