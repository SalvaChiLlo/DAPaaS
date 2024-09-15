FROM node:20.17-alpine3.20 AS builder

WORKDIR /usr/src/app

COPY ./package*.json ./

RUN npm install

COPY ./ .

ENV TZ=Europe/Madrid

ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
