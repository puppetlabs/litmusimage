ARG BASE_IMAGE_TAG
ARG OS_TYPE

FROM $OS_TYPE:$BASE_IMAGE_TAG

# Re-declare OS_TYPE & BASE_IMAGE_TAG ARGS
ARG OS_TYPE
ARG BASE_IMAGE_TAG

ENV container docker
ENV DEBIAN_FRONTEND noninteractive

# Redirect Debian 10 sources to archive.debian.org to fix expired repo issues
RUN if [ "$OS_TYPE" = "debian" ] && [ "$BASE_IMAGE_TAG" = "10" ]; then \
        sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
        sed -i 's|http://security.debian.org|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
        echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until; \
    fi

# Install system packages
RUN apt-get update \
    && apt-get install -y systemd sysvinit-utils util-linux locales locales-all wget iproute2 apt-transport-https \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Optional: Add backports for Debian 12
RUN if [ "$OS_TYPE" = "debian" ] && [ "$BASE_IMAGE_TAG" = "12" ]; then \
        echo "deb http://deb.debian.org/debian bookworm-backports main" >> /etc/apt/sources.list; \
        apt update; \
    fi

# Locale setup
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

# Profile tweak
RUN sed -i "s/.*mesg\s.*/tty -s \&\& mesg n/g" /root/.profile

# Minimize systemd units
RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
    /lib/systemd/system/systemd-update-utmp*

STOPSIGNAL SIGRTMIN+3

CMD ["/lib/systemd/systemd"]
