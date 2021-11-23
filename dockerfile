FROM node:14

COPY ./src/app/ /usr/src/app
RUN cd /usr/src/app && npm update
WORKDIR /usr/src/app

EXPOSE 3000

ENTRYPOINT [ "bash","./helper.sh" ]


