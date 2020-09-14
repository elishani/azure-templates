#!/bin/bash
apt update

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt -y install \
    docker-compose \
    curl \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    docker-ce \
    wget \
    docker-compose
sed -i 's/ClientAliveInterval 120/ClientAliveInterval 180/g' /etc/ssh/sshd_config

