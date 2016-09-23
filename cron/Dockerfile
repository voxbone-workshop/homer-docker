FROM sipcapture/homer-docker:webapp
MAINTAINER L. Mangani <lorenzo.mangani@gmail.com>
ENV BUILD_DATE 2016-09-23

# Install the cron service
RUN touch /var/log/cron.log
RUN apt-get update -qq && apt-get install cron mysql-client -y && rm -rf /var/lib/apt/lists/*

# Add our crontab file
RUN echo "30 3 * * * /opt/new/homer_rotate >> /var/log/cron.log 2>&1" > /crons.conf
RUN crontab /crons.conf

COPY rotation.ini /opt/new/rotation.ini

COPY run.sh /run.sh
RUN chmod a+rx /run.sh

ENTRYPOINT ["/run.sh"]
