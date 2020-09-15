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

my_ip=$(ip adde )
mkdir -p /var/www/rancher
cd /var/www/rancher
cat > docker-compose.yml <<EOF
version: '2'
services:
  rancher:
    image: rancher/rancher:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./rancher:/var/lib/rancher
      - ./auditlog:/var/log/auditlog
EOF

docker-compose -f docker-compose.yml up -d
