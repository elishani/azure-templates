#!/bin/bash

apt update

# Install doker engine
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce docker-ce-cli containerd.io

user=$(grep x:1000:1000:' /etc/passwd | awk -F: '{print $1}')
usermod -aG docker $user
su -c 'mkdir $HOME/.ssh' - $user
su -c 'chmod 700 $HOME/.ssh                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
' - $user
su -c 'echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2BMyRL1pvYi4JmAvsgimRQWouTehJw+dyw+LT4fGF9NQ4nVYreXDPhrjlIn7SF3RW9ynGT3unyoAj+ul0MGJYbFGGI8yPv/6f3mjego7BZQCf6OOVBQf8LDWy78KEKG7Yz5uwmrAaqszC+2C91bzG8MMEBmTm/XtUPNpwzCksaK0S7ZXQmaFThEAWGkV7vMmahBklOVUlFP0tUpxdP3SObBFFUNDgh37kP6SxrXpaLXUluGWtNoZvWsYzPkEqyZES8gJAmVg0ocqQfDnaxwiar8PQH/9prr5xDcjeFYmhTTO5hDHg5Zc9d359ZuYK4gAQ2VByongEFi1oxoJifUsJU1fFe56cd6YYn0G+8b49k+D1R5YK/n4JvoxciYOqTPGDmbDHBYKCwSlDNWh9uID/6PLrUE6NP6N/5YRJe5wawMZido+cmxRQQNjq7B5+YgQe5kSD49V1ruHWo8i18QCPDSjYFXdBTvwaQ/2AQSuBerGWkvVCtr/OJI47jj1x+50= eli@eli-Latitude-5590" >$HOME/.ssh/authorized_keys' - $user

# Run on one machine

[ -z $(hostname  | grep 'vm1$') ] && exit

resource_group_name=$1
export file_name=cluster.yml

az network public-ip list --resource-group $resource_group_name | grep '"ipAddress":' |  awk -F'"' '{print $4}' > iplist.txt

sed -e "1d" iplist.txt > vm.txt

echo "nodes:" > $file_name
i=1
for public in `cat vm.txt` ; do
vm=rancher$i
private=`ssh -o "StrictHostKeyChecking no" vm@$public /sbin/ip addr | grep 'inet 10.0' | awk '{print $2}' | cut -d'/' -f1`
host_name=`ssh vm@$public hostname`
cat >> $file_name <<EOF
  - address: $public
    internal_address: $private
    user: vm
    role: [controlplane, worker, etcd]
    hostname_override: $host_name
EOF
i=$((++i))
done