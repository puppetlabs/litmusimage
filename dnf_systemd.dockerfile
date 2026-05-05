ARG BASE_IMAGE_TAG
ARG OS_TYPE

FROM $OS_TYPE:$BASE_IMAGE_TAG

ENV container docker

RUN echo "LC_ALL=en_US.utf-8" >> /etc/locale.conf

RUN dnf -y install openssh-server openssh-clients systemd initscripts glibc-langpack-en iproute wget ; \
    dnf -y reinstall dbus ; \
    dnf clean all ; \
    ssh-keygen -A ; \
    touch /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_dsa_key.pub

# On EL8 images, upgrade iptables and switch to the legacy backend.
# iptables-nft (the EL8 default) fails with RULE_APPEND ENOENT on -m limit
# rules when run inside Docker on a newer host kernel because the older
# nft_compat ABI is incompatible. iptables-legacy bypasses nf_tables
# entirely and avoids the issue. AlmaLinux 8 base images already ship a
# recent enough iptables; Rocky 8 does not, so the update is required there.
# The alternatives --set calls are idempotent if legacy is already default.
RUN . /etc/os-release; \
    if [ "${VERSION_ID%%.*}" = "8" ]; then \
        dnf update -y iptables iptables-services 2>/dev/null || true; \
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

CMD ["/lib/systemd/systemd"]
