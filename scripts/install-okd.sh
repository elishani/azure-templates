#!/bin/bash

user=$1
if [ -z $user ]; then
    echo "ERROR: Need paramter user"
    exit 1
fi
ip=$2
echo "User='$user'"
echo "Ip='$ip'"
user_home=/home/$user

yum -y update --exclude=WALinuxAgent
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y  docker-ce docker-ce-cli containerd.io

usermod -aG docker $user
systemctl start docker
systemctl enable docker

mkdir /etc/docker /etc/containers

tee /etc/containers/registries.conf<<EOF
[registries.insecure]
registries = ['172.30.0.0/16']
EOF

tee /etc/docker/daemon.json<<EOF
{
   "insecure-registries": [
     "172.30.0.0/16"
   ]
}
EOF

systemctl daemon-reload
systemctl restart docker

echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
 
cd $user_home
wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz

tar xvf openshift-origin-client-tools*.tar.gz
cd openshift-origin-client-tools*
mv  oc kubectl  /usr/local/bin/
echo "PATH=$PATH:/usr/local/bin" >> /etc/profile
cd $user_home

echo "Running cluster"

file=$user_home/start_cluster
echo "newgrp docker << END" > $file
echo "oc cluster up --public-hostname=$ip --routing-suffix=$ip.xip.io" >> $file
echo "END" >> $file

systemctl restart docker

echo "****************** END ******************"