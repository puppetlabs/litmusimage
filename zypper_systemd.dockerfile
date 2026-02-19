ARG BASE_IMAGE_TAG
ARG OS_TYPE

FROM $OS_TYPE:$BASE_IMAGE_TAG

ENV container docker

# Add openSUSE Leap repository if no repos are configured (workaround for unregistered SLES BYOS images)
RUN if ! zypper lr 2>/dev/null | grep -q 'http'; then \
      zypper --non-interactive --gpg-auto-import-keys ar http://download.opensuse.org/distribution/leap/15.6/repo/oss/ opensuse-leap-fallback && \
      zypper --non-interactive --gpg-auto-import-keys ref -s; \
    else \
      zypper ref -s; \
    fi && \
    zypper -n install openssh-server systemd glibc-locale-base iproute2 gzip bzip2 && \
    zypper -n install --force dbus-1 && \
    zypper -n clean --all && \
    systemctl enable sshd

RUN echo "LANG=en_US.UTF-8" >/etc/locale.conf ; echo "KEYMAP=us" >/etc/vconsole.conf

RUN (cd /usr/lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /usr/lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/getty.target.wants/*;\
rm -f /usr/lib/systemd/system/local-fs.target.wants/*; \
rm -f /usr/lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /usr/lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /usr/lib/systemd/system/basic.target.wants/*;\
rm -f /usr/lib/systemd/system/anaconda.target.wants/*;

STOPSIGNAL SIGRTMIN+3

CMD /usr/lib/systemd/systemd
