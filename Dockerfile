# see https://docs.docker.com/docker-cloud/builds/advanced/
# using ARG in FROM requires min v17.05.0-ce
FROM  ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive


RUN apt update
RUN apt-get install -y  gfortran
RUN apt-get install -y  liblapack-dev
RUN apt-get install -y  libfftw3-dev
RUN apt-get install -y  libnetcdf-dev
RUN apt-get install -y  libnetcdff-dev
RUN apt-get install -y  libopenmpi-dev
RUN apt install -y build-essential