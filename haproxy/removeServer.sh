#!/bin/bash
NAME='webserver02' # $1
ADDRESS='15.29.219.177' #$2
PORT='8000' #$3
sed -i "/server\ $NAME\ $ADDRESS:$PORT\ check/d" conf/haproxy.cfg

