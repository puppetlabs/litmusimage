ARG BASE_IMAGE_TAG
ARG OS_TYPE

FROM $OS_TYPE:$BASE_IMAGE_TAG

# Re-declare OS_TYPE & BASE_IMAGE_TAG ARGS
ARG OS_TYPE
ARG BASE_IMAGE_TAG

ENV container docker

# Test CentOS 7 with ubuntu-22.04 runner for compatibility

RUN echo "LC_ALL=en_US.utf-8" >> /etc/locale.conf

RUN if [[ ( "$OS_TYPE" = "quay.io/centos/centos" && "$BASE_IMAGE_TAG" = "stream8" ) || ( "$OS_TYPE" = "centos" && "$BASE_IMAGE_TAG" = "7" ) ]]; then \
  for file in /etc/yum.repos.d/CentOS-*; do \
    sed -i 's/mirrorlist/#mirrorlist/g' "$file"; \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' "$file"; \
  done; \
fi

RUN if [[ ( "$OS_TYPE" = "scientificlinux/sl" && "$BASE_IMAGE_TAG" = "7" ) ]]; then \
  for file in /etc/yum.repos.d/*.repo; do \
    sed -i 's/mirrorlist/#mirrorlist/g' "$file"; \
    sed -i 's|^baseurl=http://ftp.scientificlinux.org/linux/scientific/|baseurl=http://ftp.scientificlinux.org/linux/scientific/obsolete/|g' "$file"; \
  done; \
fi

RUN yum -y install openssh-server openssh-clients systemd initscripts glibc-langpack-en iproute wget; yum -y reinstall dbus; yum clean all; systemctl enable sshd.service

# On EL8 images (CentOS Stream 8, OracleLinux 8, RHEL UBI 8), upgrade
# iptables and switch to the legacy backend. iptables-nft fails with
# RULE_APPEND ENOENT on -m limit rules inside Docker on newer host kernels
# due to an nft_compat ABI mismatch. The legacy backend bypasses nf_tables.
RUN . /etc/os-release 2>/dev/null || true; \
    if [ "${VERSION_ID%%.*}" = "8" ] && [ "$ID" = "centos" ]; then \
        yum update -y iptables iptables-services 2>/dev/null || true; \
        if [ -x /usr/sbin/iptables-legacy ]; then \
            alternatives --set iptables  /usr/sbin/iptables-legacy  2>/dev/null || true; \
            alternatives --set ip6tables /usr/sbin/ip6tables-legacy 2>/dev/null || true; \
        fi; \
    fi

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