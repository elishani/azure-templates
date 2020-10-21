#!/bin/bash
exit

user=$1
ip=$2
echo "User='$user'"
echo "Ip='$ip'"
user_home=/home/$user

yum -y update
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y  docker-ce docker-ce-cli containerd.io

usermod -aG docker $user

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

systemctl enable docker
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
 
cd $user_home
wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
tar xvf openshift-origin-client-tools*.tar.gz
cd openshift-origin-client-tools*
mv  oc kubectl  /usr/local/bin/
cd $user_home

file=$user_home/start_cluster
echo "newgrp docker << END" > $file
echo "oc cluster up" >> $file
echo "END" >> $file 

su -c "bash $file" - $user
