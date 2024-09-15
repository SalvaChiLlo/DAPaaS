FROM debian:stable

WORKDIR /bin

COPY ./scripts/* .

RUN apt update -y && apt install -y wget openssh-client openssh-server

ENV TZ=Europe/Madrid

ENTRYPOINT [ "/bin/setup_sync.sh" ]