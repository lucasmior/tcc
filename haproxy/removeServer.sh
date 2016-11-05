#!/bin/bash
NAME='webserver02' # $1
ADDRESS='15.29.219.177' #$2
PORT='7002' #$3
sed -i "/server.*$ADDRESS:$PORT\ check/d" conf/haproxy.cfg

