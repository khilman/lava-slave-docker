FROM bitnami/minideb:unstable

# Add services helper utilities to start and stop LAVA
COPY scripts/stop.sh .
COPY scripts/start.sh .

RUN \
 echo 'lava-server   lava-server/instance-name string lava-slave-instance' | debconf-set-selections && \
 echo 'locales locales/locales_to_be_generated multiselect C.UTF-8 UTF-8, en_US.UTF-8 UTF-8 ' | debconf-set-selections && \
 echo 'locales locales/default_environment_locale select en_US.UTF-8' | debconf-set-selections && \
 DEBIAN_FRONTEND=noninteractive install_packages \
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
 qemu-system-i386 \
 qemu-kvm 

# Additional packages
RUN apt-get update && \
 apt-get install --yes conmux python-setproctitle tftpd-hpa u-boot-tools device-tree-compiler iputils-ping net-tools 
 
# acme-cl.i
RUN \
 git clone https://github.com/baylibre-acme/acme-cli.git /root/acme-cli && \
 cp /root/acme-cli/acme-cli /usr/local/bin
 
RUN \
 git clone https://github.com/kernelci/lava-server.git -b release /root/lava-server && \
 git clone https://github.com/kernelci/lava-dispatcher.git -b master /root/lava-dispatcher && \
 cd /root/lava-dispatcher && \
 git checkout release && \
 git config --global user.name "Docker Build" && \
 git config --global user.email "info@kernelci.org" && \
 echo "cd \${DIR} && dpkg -i *.deb" >> /root/lava-server/share/debian-dev-build.sh && \
 sleep 2 && \
 /root/lava-server/share/debian-dev-build.sh -p lava-dispatcher

COPY configs/lava-slave /etc/lava-dispatcher/lava-slave

COPY configs/tftpd-hpa /etc/default/tftpd-hpa

EXPOSE 69/udp

CMD /start.sh && bash
