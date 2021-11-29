FROM node:14

COPY ./src/app/ /usr/src/app
WORKDIR /usr/src/app
RUN chmod -R 777 /usr/src/app
RUN cd /usr/src/app && npm i

### Installations
RUN apt-get update && apt-get install -y \
    cron \
    vim \
    net-tools \
    iputils-ping

### CRONJOBS ######
#0 * * * *   -> At minute 0 (every hour) 
RUN echo "PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin" >> /etc/cron.d/crontab
RUN echo '* * * * * root node /usr/src/app/cleaner.js >> /dev/null 2>&1' >> /etc/cron.d/crontab

###################

EXPOSE 3000

CMD service cron start \
    && crontab /etc/cron.d/crontab \
    && bash ./helper.sh


