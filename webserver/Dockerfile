FROM ubuntu

ENV \
  http_proxy=http://web-proxy.corp.hp.com:8080 \
  https_proxy=http://web-proxy.corp.hp.com:8080/ \
  DEBIAN_FRONTEND=noninteractive

RUN \
  echo 'Acquire::http::Proxy "http://web-proxy.corp.hp.com:8080/";' >> /etc/apt/apt.conf ;\
  echo 'Acquire::https::Proxy "http://web-proxy.corp.hp.com:8080/";' >> /etc/apt/apt.conf

RUN \
  apt-get -qq update && \
  apt-get -qq upgrade

RUN \
  apt-get install -y apache2

RUN \
  echo "\
  <html>\
    <body>\
      <h1>hello world</h1>\
    </body>\
  </html>" > /var/www/html/index.html

#RUN echo ServerName ${HOSTNAME} >> /etc/httpd/conf/httpd.conf

RUN \
#  echo $(/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}') >> /var/www/html/index.html
  echo $(echo $(hostname -i) >> /var/www/html/index.html) > /var/www/html/host.sh 

#RUN \
#  service apache2 start
CMD ["/var/www/html/host.sh", "/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

EXPOSE 80
