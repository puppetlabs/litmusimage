ARG BASE_IMAGE_TAG
ARG OS_TYPE

FROM $OS_TYPE:$BASE_IMAGE_TAG

RUN apt-get update \
    && apt-get install -y wget locales apt-transport-https curl

RUN rm /usr/sbin/policy-rc.d \
    && rm /sbin/initctl \
    && dpkg-divert --rename --remove /sbin/initctl \
    && locale-gen en_US.UTF-8
RUN sed -i "s/.*mesg\s.*/tty -s \&\& mesg n/g" /root/.profile

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

LABEL base_image=""
LABEL test='test'

CMD ["/sbin/init"]
