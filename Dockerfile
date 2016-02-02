FROM ubuntu:14.04

MAINTAINER Gaurav Ashtikar gau1991@gmail.com

RUN echo "0.1" > /VERSION

RUN apt-get update

# Install pre packages required for EasyEngine
RUN apt-get install -y build-essential wget git python3-setuptools python3-dev python3-apt sudo cron anacron psmisc rsyslog vim whois runit socat &&\
  sed -i -e 's/start -q anacron/anacron -s/' /etc/cron.d/anacron &&\
  sed -i.bak 's/$ModLoad imklog/#$ModLoad imklog/' /etc/rsyslog.conf &&\
  mkdir -p /etc/runit/1.d

# Set Git user name and password so that EasyEngine will not ask that
RUN bash -c 'echo -e "[user]\n\tname = abc\n\temail = root@localhost.com" > /root/.gitconfig'

# Install EasyEngine
RUN wget rt.cx/ee && bash ee

# Install Nginx and PHP
RUN LC_ALL=en_US.UTF-8 ee stack install --nginx --php

# clean up for docker squash
RUN rm -fr /usr/share/man && rm -fr /usr/share/doc && mkdir -p /etc/runit/3.d
ADD runit-1 /etc/runit/1
ADD runit-1.d-cleanup-pids /etc/runit/1.d/cleanup-pids
ADD runit-1.d-anacron /etc/runit/1.d/anacron
ADD runit-2 /etc/runit/2
ADD runit-3 /etc/runit/3
ADD boot /sbin/boot

ADD cron /etc/service/cron/run
ADD rsyslog /etc/service/rsyslog/run
ADD nginx /etc/service/nginx/run
ADD php5-fpm /etc/service/php5-fpm/run
