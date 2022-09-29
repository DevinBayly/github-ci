# see https://docs.docker.com/docker-cloud/builds/advanced/
# using ARG in FROM requires min v17.05.0-ce
FROM  ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive


RUN apt update
RUN apt install -y xvfb
RUN apt install -y wget 
RUN apt install -y libglfw3 libglfw3-dev
RUN apt install -y libxi-dev
RUN apt install -y xz-utils