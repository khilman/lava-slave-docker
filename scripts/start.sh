#!/bin/bash
# Set LAVA Master IP
if [[ -n "$LAVA_MASTER" ]]; then
	sed -i -e "s/{LAVA_MASTER}/$LAVA_MASTER/g" /etc/lava-dispatcher/lava-slave
fi
service tftpd-hpa start
service lava-slave start

# start an http file server for boot/transfer_overlay support
(cd /var/lib/lava/dispatcher; python -m SimpleHTTPServer 80 &)

