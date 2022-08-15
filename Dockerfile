FROM ros:melodic-ros-core-bionic
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update

RUN apt install -y ros-melodic-desktop-full
RUN apt install -y ros-melodic-slam-gmapping wget
## dependencies for lego loam
# RUN wget -O gtsam.zip https://github.com/borglab/gtsam/archive/4.0.0-alpha2.zip
# RUN unzip gtsam.zip 
# RUN ls
# WORKDIR gtsam-4.0.0-alpha2/
# # CMake
# # google-glog + gflags
# RUN apt-get install -y libgoogle-glog-dev libgflags-dev
# # Use ATLAS for BLAS & LAPACK
# RUN apt-get install -y libatlas-base-dev
# # Eigen3
# RUN apt-get install -y libeigen3-dev
# SuiteSparse (optional)
# RUN apt-get install -y libsuitesparse-dev
# RUN mkdir build
# WORKDIR build
# RUN pwd
# RUN apt-get install -y cmake 
# RUN apt install -y build-essential
# RUN cmake ..
# RUN make install -j$(nproc)


# # #pcl stuff
# RUN apt install -y libpcl-dev
# RUN apt install -y python-rosdep

# RUN /usr/bin/rosdep init

# WORKDIR /
# RUN apt install ros-melodic-ros-core ros-melodic-pcl-ros \
#      ros-melodic-tf2-geometry-msgs ros-melodic-rviz
# RUN mkdir -p lego_catkin/src
# WORKDIR lego_catkin
# RUN rm /bin/sh && ln -s /bin/bash /bin/sh
# RUN apt install -y git
# WORKDIR src
# RUN git clone https://github.com/RobustFieldAutonomyLab/LeGO-LOAM
# RUN git clone https://github.com/ouster-lidar/ouster_example.git
# WORKDIR ../
# RUN source /opt/ros/melodic/setup.bash && catkin_make -j1
# RUN apt install build-essential cmake libeigen3-dev libjsoncpp-dev
# RUN echo "done"
# RUN wget "http://ceres-solver.org/ceres-solver-2.1.0.tar.gz"
# RUN tar zxf ceres-solver-2.1.0.tar.gz
# RUN mkdir ceres-bin
# WORKDIR ceres-bin
# RUN cmake ../ceres-solver-2.1.0
# RUN make -j$(nproc)
# RUN make test
# # # Optionally install Ceres, it can also be exported using CMake which
# # # allows Ceres to be used without requiring installation, see the documentation
# # # for the EXPORT_BUILD_DIR option for more information.
# RUN make install
