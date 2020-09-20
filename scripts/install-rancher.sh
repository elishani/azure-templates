#!/bin/bash

apt update

# Install doker engine
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce docker-ce-cli containerd.io

user=$(grep ':x:1000:1000:' /etc/passwd | awk -F: '{print $1}')
usermod -aG docker $user
su -c 'mkdir $HOME/.ssh' - $user
su -c 'chmod 700 $HOME/.ssh ' - $user
su -c 'touch $HOME/.ssh/authorized_keys' - $user

