FROM jenkins/inbound-agent:latest

USER root

RUN apt-get update && apt-get install -y \
    build-essential \
    rpm \
    && rm -rf /var/lib/apt/lists/*

USER jenkins

