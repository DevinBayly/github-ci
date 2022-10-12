FROM ghcr.io/devinbayly/vtk:latest
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y xserver-xorg-video-dummy
