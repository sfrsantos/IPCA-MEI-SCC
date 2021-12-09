FROM node:14

### Data of the app
WORKDIR /usr/src/app
COPY ./src/app/ .
RUN rm -rf node_modules && rm ./package-lock.json && npm install

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
RUN crontab /etc/cron.d/crontab

### Expose port
EXPOSE 3000

### Run when container up
ENTRYPOINT ["bash","startup.sh"] 


