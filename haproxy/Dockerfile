FROM haproxy:1.6
#COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
#COPY test.cfg /usr/local/etc/haproxy/haproxy.cfg

ENV \
  http_proxy=http://web-proxy.boi.hp.com:8080 \
  https_proxy=http://web-proxy.boi.hp.com:8080 \
  DEBIAN_FRONTEND=noninteractive \
  TERM=xterm \
  CONFIG="/usr/local/etc/haproxy/haproxy.cfg" \
  PIDFILE="/run/haproxy.pid"

  

RUN \
  echo 'Acquire::http::Proxy "http://web-proxy.boi.hp.com:8080/";' >> /etc/apt/apt.conf ;\
  echo 'Acquire::https::Proxy "http://web-proxy.boi.hp.com:8080/";' >> /etc/apt/apt.conf

RUN \
  apt-get -qq update &&\
  apt-get -qq install \
	vim \
	inotify-tools

COPY reload.sh /reload.sh
COPY reload.sh /bin/reload

RUN chmod +x /bin/reload
#COPY docker-entrypoint.sh /docker-entrypoint.sh

#RUN \
#  chmod 777 /docker-entrypoint.sh 
#  echo 524288 > /proc/sys/fs/inotify/max_user_watches
#  echo "while inotifywait -e close_write /usr/local/etc/haproxy/haproxy.cfg; do haproxy -f /usr/local/etc/haproxy/haproxy.cfg -p /run/haproxy.pid -sf $(< $(cat $PIDFILE)); done &" > /reload.sh

#ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]
#ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg", "-p", "/run/haproxy.pid", "-sf", "$(< $(cat $PIDFILE))"]
#CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
#, "-p", "/run/haproxy.pid", "-sf", "$(< $(cat $PIDFILE))"]
