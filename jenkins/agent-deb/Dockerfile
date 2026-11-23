FROM jenkins/inbound-agent:latest

USER root

RUN apt-get update && apt-get install -y \
    build-essential \
    dpkg-dev \
    debhelper \
    devscripts \
    fakeroot \
    lintian \
    && rm -rf /var/lib/apt/lists/*

USER jenkins
