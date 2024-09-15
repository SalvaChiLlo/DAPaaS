FROM debian:stable

WORKDIR /bin

COPY ./scripts/* .

RUN apt update -y && apt install -y wget openssh-client

RUN wget https://github.com/mutagen-io/mutagen/releases/download/v0.17.6/mutagen_linux_amd64_v0.17.6.tar.gz \
  && tar -xvaf mutagen_linux_amd64_v0.17.6.tar.gz

ENV TZ=Europe/Madrid

ENTRYPOINT [ "/bin/setup_sync.sh" ]