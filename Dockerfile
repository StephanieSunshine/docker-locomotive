# See: https://github.com/phusion/passenger-docker
# Latest image versions: https://github.com/phusion/passenger-docker/blob/master/Changelog.md
FROM phusion/passenger-ruby22
MAINTAINER Stephanie Sunshine <ponyosunshine@gmail.com>

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

RUN apt-get update -qq && apt-get install -qy wget curl gnupg ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "America/Los_Angeles" > /etc/timezone
#RUN ruby-switch --set ruby2.2
RUN locale-gen en_US.utf8
ENV LANG en_US.utf8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.utf8

RUN /usr/sbin/usermod -u 999 app
RUN /usr/sbin/groupmod -g 999 app
WORKDIR /home/app
EXPOSE 80 443 3000
ADD entrypoint.sh /sbin/
RUN chmod 755 /sbin/entrypoint.sh
RUN mkdir -p /etc/my_init.d
RUN ln -s /sbin/entrypoint.sh /etc/my_init.d/entrypoint.sh
ENTRYPOINT ["/sbin/entrypoint.sh"]
