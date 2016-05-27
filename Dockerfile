##########################################
# Dockerfile to run Pegasus
# Based on Debian
###########################################
FROM debian:jessie

MAINTAINER Austin Ouyang

RUN apt-get update \
    && apt-get install -y vim \
    && apt-get install -y openssh-client \
    && apt-get install -y python \
    && apt-get install -y python-dev \
    && apt-get install -y python-pip

RUN pip install awscli

ENV PEGASUS_HOME /root/pegasus
ENV PATH $PEGASUS_HOME:$PATH
ENV REM_USER ubuntu

COPY . /root/pegasus

RUN echo "source pegasus-completion.sh" >> /root/.bashrc

WORKDIR /root

