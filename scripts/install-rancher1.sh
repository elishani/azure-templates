#!/bin/bash

myIp=$(ip addr  show eth0 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
preIp=$(echo $myIp | cut -d'.' -f1-3)
postIp=$(echo $myIp | cut -d'.' -f4)
upIp="$preIp.$((postIp+1))"
downIp="$preIp.$((postIp-1))"

i=0
limit=5

while true; do
	ping -c1 $upIp
	if [ $? = 0  ]; then
		station2=$upIp
		break
	fi
	ping -c1 $downIp
	if [ $? = 0  ]; then
                station2=$downIp
                break
	fi
	((i+=1))
	[ $i = $limit ] && break
done
if [ -z $station2 ]; then
	echo "No ping to other machine"
	exit 1
fi

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
