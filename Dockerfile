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
    && apt-get install -y python-pip \
    && apt-get install -y git

RUN pip install awscli

RUN git clone https://github.com/sstephenson/bats.git /root/bats

RUN /root/bats/install.sh /usr/local

ENV PEGASUS_HOME /root/pegasus
ENV PATH $PEGASUS_HOME:$PATH
ENV REM_USER ubuntu

COPY . /root/pegasus

RUN echo "source pegasus-completion.sh" >> /root/.bashrc

WORKDIR /root

