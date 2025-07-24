ARG BASE_IMAGE_TAG
ARG OS_TYPE

FROM $OS_TYPE:$BASE_IMAGE_TAG

# Re-declare OS_TYPE & BASE_IMAGE_TAG ARGS
ARG OS_TYPE
ARG BASE_IMAGE_TAG

ENV container docker

RUN echo "LC_ALL=en_US.utf-8" >> /etc/locale.conf

RUN if [[ ( "$OS_TYPE" = "quay.io/centos/centos" && "$BASE_IMAGE_TAG" = "stream8" ) ]]; then \
  for file in /etc/yum.repos.d/CentOS-*; do \
    sed -i 's/mirrorlist/#mirrorlist/g' "$file"; \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' "$file"; \
  done; \
fi

RUN yum -y install openssh-server openssh-clients systemd initscripts glibc-langpack-en iproute; yum -y reinstall dbus; yum clean all; systemctl enable sshd.service

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

STOPSIGNAL SIGRTMIN+3

CMD /usr/sbin/init
