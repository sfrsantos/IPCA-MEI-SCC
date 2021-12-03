#!/bin/bash

export $(grep -v '^#' .env | sed 's/#.*\]//g' |  xargs)

## Init
#service cron start
ls -lah | grep node_modules >> /dev/null 2>&1 || npm i  \

#run migrations
#npx prisma migrate dev

## Run App
echo "Starting application..."
echo "App running in $APP_MODE mode!"
npm run-script $APP_MODE