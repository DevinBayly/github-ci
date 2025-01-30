from ubuntu:latest
RUN apt update
# RUN apt-get install -y  gfortran
# RUN apt-get install -y  liblapack-dev
# RUN apt-get install -y  libfftw3-dev
# RUN apt-get install -y  libnetcdf-dev
# RUN apt-get install -y  libnetcdff-dev
# RUN apt-get install -y  libopenmpi-dev
RUN apt install -y build-essential
RUN echo DONE
