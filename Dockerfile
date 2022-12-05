FROM selenium/standalone-chrome
ARG DEBIAN_FRONTEND=noninteractive

USER root
RUN apt update
RUN apt-get install -y  python3-pip
USER seluser
RUN pip install selenium
RUN pip install webdriver_manager