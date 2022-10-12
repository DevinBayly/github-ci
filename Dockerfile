FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y cmake build-essential
RUN apt install -y libglfw3-dev
RUN apt install -y curl
RUN curl "https://vtk.org/files/release/9.1/VTK-9.1.0.tar.gz" >vtk.tar
RUN tar xf vtk.tar 
WORKDIR VTK-9.1.0/
RUN ls
RUN mkdir build
WORKDIR /VTK-9.1.0/build
RUN cmake ../
RUN make install -j $(nproc)
RUN apt install -y xserver-xorg-video-dummy
