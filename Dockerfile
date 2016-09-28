FROM ubuntu:14.04

MAINTAINER 'PUCRS, Lucas Mior. <lucas.mior@acad.pucrs.com>'

ENV \
  http_proxy=http://web-proxy.boi.hp.com:8080 \
  https_proxy=http://web-proxy.boi.hp.com:8080 \
  DEBIAN_FRONTEND=noninteractive

RUN \
  echo 'Acquire::http::Proxy "http://web-proxy.boi.hp.com:8080/";' >> /etc/apt/apt.conf ;\
  echo 'Acquire::https::Proxy "http://web-proxy.boi.hp.com:8080/";' >> /etc/apt/apt.conf

# Generate locale UTF-8
#
RUN locale-gen en_US.UTF-8

# Set environment variables
#
#ENV \
#  COPY_REFERENCE_FILE_LOG=/tmp/copy_reference_file.log \
#  LANG=en_US.UTF-8 \
#  LANGUAGE=en_US:en \
#  LC_ALL=en_US.UTF-8

# apt-get install: 
#   curl: used to download jenkins.
#   software-properties-common: used to add openjdk-8-jdk apt source.
#   openjdk-8-jdk: used to run jenkins.
#   git: tiamat-rules gem dependency.
#   other packages: ruby dependencies.
#
#RUN \
#  apt-get -qq update &&\
#  apt-get -qq install \
#    curl \
#    software-properties-common \
#    patch \
#    gawk \
#    g++ \
#    gcc \
#    make \
#    libc6-dev \
#    patch \
#    libreadline6-dev \
#    zlib1g-dev \
#    libssl-dev \
#    libyaml-dev \
#    libsqlite3-dev \
#    sqlite3 \
#    autoconf \
#    libgdbm-dev \
#    libncurses5-dev \
#    automake \
#    libtool \
#    bison \
#    pkg-config \
#    libffi-dev \
#    git &&\
#  add-apt-repository -y ppa:openjdk-r/ppa &&\
#  apt-get -qq update &&\
#  apt-get -qq install openjdk-8-jdk &&\
#  rm -rf /var/lib/apt/lists/*

# Download tini (https://github.com/krallin/tini)
# Tini is used as subreaper in Docker container to adopt zombie processes
#
#RUN \
#  curl -fL https://github.com/krallin/tini/releases/download/v0.5.0/tini-static -o /bin/tini &&\
#  chmod +x /bin/tini

# Expose port for main web interface
#
EXPOSE 8080
#
# Install rvm and ruby
#
#RUN \
#  gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 &&\
#  curl -sSL https://get.rvm.io | sudo -E bash -s stable &&\
#  gpasswd -a jenkins rvm && \
#  bash -l -c 'rvm install 2.1.5' &&\
#  bash -l -c 'rvm use 2.1.5 --default'

# Configure the LABEL version and vendor
#
LABEL vendor="Lucas Mior"
