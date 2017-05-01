FROM linarotechnologies/minideb:stretch-arm64

# Add services helper utilities to start and stop LAVA
COPY stop.sh .
COPY start.sh .

RUN \
 echo 'lava-server   lava-server/instance-name string lava-slave-instance' | debconf-set-selections && \
 echo 'locales locales/locales_to_be_generated multiselect C.UTF-8 UTF-8, en_US.UTF-8 UTF-8 ' | debconf-set-selections && \
 echo 'locales locales/default_environment_locale select en_US.UTF-8' | debconf-set-selections && \
 apt-get update && \
 DEBIAN_FRONTEND=noninteractive apt-get install -y \
 locales \
 lava-dispatcher \
 lava-dev \
 git \
 vim \
 sudo \
 python-setproctitle \
 tftpd-hpa \
 u-boot-tools \
 device-tree-compiler \
 qemu-system \
 qemu-system-arm \
 qemu-system-i386 && \
 rm -rf /var/lib/apt/lists/*

RUN \
 git clone -b master https://git.linaro.org/lava/lava-dispatcher.git /root/lava-dispatcher && \
 cd /root/lava-dispatcher && \
 git checkout 2017.2 && \
 echo "cd \${DIR} && dpkg -i *.deb" >> /usr/share/lava-server/debian-dev-build.sh && \
 sleep 2 && \
 /usr/share/lava-server/debian-dev-build.sh -p lava-dispatcher

COPY configs/lava-slave /etc/lava-dispatcher/lava-slave

COPY configs/tftpd-hpa /etc/default/tftpd-hpa

EXPOSE 69/udp

CMD /start.sh && bash
