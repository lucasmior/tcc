#while inotifywait -e close_write /usr/local/etc/haproxy/haproxy.cfg; do haproxy -f /usr/local/etc/haproxy/haproxy.cfg -p /run/haproxy.pid -sf $(</run/haproxy.pid); done &
haproxy -f /usr/local/etc/haproxy/haproxy.cfg -p /run/haproxy.pid -sf $(</run/haproxy.pid)
