#!/bin/bash

#set -x; bash reload.sh
#set -x; exec haproxy -f /usr/local/etc/haproxy/haproxy.cfg
haproxy -f /usr/local/etc/haproxy/haproxy.cfg

while [ 1 ]; do
  #./haproxy -f /tmp/haproxy.cfg -p /tmp/haproxy.pid -sf $(cat /tmp/haproxy.pid)
  haproxy -f /usr/local/etc/haproxy/haproxy.cfg -p /run/haproxy.pid -sf $(</run/haproxy.pid);
  sleep 1
done

while inotifywait -e close_write /usr/local/etc/haproxy/haproxy.cfg; do 
done

while inotifywait -e close_write /usr/local/etc/haproxy/haproxy.cfg; do      
  haproxy -f /usr/local/etc/haproxy/haproxy.cfg -p /run/haproxy.pid -sf $(</run/haproxy.pid);
done

while inotifywait -e close_write /usr/local/etc/haproxy/haproxy.cfg; do      
  haproxy -f /usr/local/etc/haproxy/haproxy.cfg -p /run/haproxy.pid -sf $(</run/haproxy.pid);
done

#set -e

# first arg is `-f` or `--some-option`
#if [ "${1#-}" != "$1" ]; then
#	set -- haproxy "$@"
#fi

#if [ "$1" = 'haproxy' ]; then
#	# if the user wants "haproxy", let's use "haproxy-systemd-wrapper" instead so we can have proper reloadability implemented by upstream
#	shift # "haproxy"
#	set -- "$(which haproxy-systemd-wrapper)" -p /run/haproxy.pid "$@"
#fi

#exec "$@"
