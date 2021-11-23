#!/bin/bash

export $(grep -v '^#' .env | sed 's/#.*\]//g' |  xargs)

echo "Updating packages..."
#npm update
echo "Packages are successful update!"

#run migrations
#npx prisma migrate dev


echo "Starting application..."
echo "App running in $APP_MODE mode!"
if [ "$APP_MODE" == "PROD" ]; then
  node app.js
else
  npm start
fi