FROM ubuntu:14.04

MAINTAINER Gaurav Ashtikar gau1991@gmail.com

RUN echo "0.1" > /VERSION

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

# Install pre packages required for EasyEngine
RUN apt-get install -y build-essential wget git python3-setuptools python3-dev python3-apt sudo cron vim whois python-setuptools curl git unzip

# Set Git user name and password so that EasyEngine will not ask that
RUN bash -c 'echo -e "[user]\n\tname = abc\n\temail = root@localhost.com" > /root/.gitconfig'

# Install EasyEngine
RUN wget rt.cx/ee && bash ee

# Install Nginx and PHP
RUN LC_ALL=en_US.UTF-8 ee stack install --nginx --php

# Supervisor Config
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout
ADD ./supervisord.conf /etc/supervisord.conf

# private expose
EXPOSE 22222
EXPOSE 80

CMD ["/bin/bash", "/start.sh"]
