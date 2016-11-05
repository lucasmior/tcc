FROM python:3.4

MAINTAINER 'Lucas Mior. <lucas.mior@gmail.com>'

ENV \
  http_proxy=http://web-proxy.boi.hp.com:8080 \
  https_proxy=http://web-proxy.boi.hp.com:8080 \
  DEBIAN_FRONTEND=noninteractive

RUN \
  echo 'Acquire::http::Proxy "http://web-proxy.boi.hp.com:8080/";' >> /etc/apt/apt.conf ;\
  echo 'Acquire::https::Proxy "http://web-proxy.boi.hp.com:8080/";' >> /etc/apt/apt.conf

EXPOSE 8070

RUN \
  pip install Flask ;\
  mkdir /app

COPY /app /app

WORKDIR /app

ENTRYPOINT ["python3", "app.py"]
