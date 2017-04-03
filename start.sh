#!/bin/bash
sed -i -e "s/{LAVA_MASTER}/$LAVA_MASTER/g" /etc/lava-dispatcher/lava-slave
service tftpd-hpa start
service lava-slave start

