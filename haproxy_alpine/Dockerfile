FROM ubuntu

ENV \
  http_proxy=http://web-proxy.boi.hp.com:8080 \
  https_proxy=http://web-proxy.boi.hp.com:8080 \
  DEBIAN_FRONTEND=noninteractive

RUN \
  echo 'Acquire::http::Proxy "http://web-proxy.boi.hp.com:8080/";' >> /etc/apt/apt.conf ;\
  echo 'Acquire::https::Proxy "http://web-proxy.boi.hp.com:8080/";' >> /etc/apt/apt.conf

RUN apt-get -qq update 
RUN apt-get -qq install haproxy

EXPOSE 80

CMD ["haproxy", "-f", "/etc/haproxy/haproxy.cfg"]
