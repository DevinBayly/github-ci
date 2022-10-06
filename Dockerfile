FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y xserver-xorg-video-dummy
RUN apt install -y x11-apps
RUN useradd -m dev
