FROM node:14

COPY ./src/app/ /usr/src/app
WORKDIR /usr/src/app

EXPOSE 3000
RUN npm i
CMD [ "npm","start" ]
