FROM node:14

COPY ./src/app/ /usr/src/app
WORKDIR /usr/src/app
RUN cd /usr/src/app && npm i


EXPOSE 3000

RUN chmod 755 ./helper.sh
ENTRYPOINT [ "bash","./helper.sh" ]


