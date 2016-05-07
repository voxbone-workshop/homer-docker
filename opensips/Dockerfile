FROM debian:jessie
MAINTAINER L. Mangani <lorenzo.mangani@gmail.com>
# v.5.05

# Default baseimage settings
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Update and upgrade apt
RUN apt-get update -qq

# OpenSIPS + sipcapture module
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5F2FBB7C
echo "deb http://apt.opensips.org jessie 2.2-nightly" >>/etc/apt/sources.list
RUN apt-get update -qq && apt-get install -f -yqq opensips* rsyslog 

COPY opensips.cfg /usr/local/opensips/etc/opensips/opensips.cfg
RUN chmod 775 /usr/local/opensips/etc/opensips/opensips.cfg

# GeoIP (http://dev.maxmind.com/geoip/legacy/geolite/)
# RUN cd /usr/share/GeoIP && curl http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz > GeoLiteCity.dat.gz && gunzip GeoLiteCity.dat.gz

COPY run.sh /run.sh

# HEP
EXPOSE 5062
EXPOSE 9060

ENTRYPOINT ["/run.sh"]
