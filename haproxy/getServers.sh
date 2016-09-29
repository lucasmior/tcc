#!/bin/bash
sed -n '/#BEGIN_SERVERS/,/#END_SERVERS/p' conf/haproxy.cfg

