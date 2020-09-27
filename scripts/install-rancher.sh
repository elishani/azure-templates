#!/bin/bash

apt update

# Install doker engine
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce docker-ce-cli containerd.io

user=$(grep 'x:1000:1000:' /etc/passwd | awk -F: '{print $1}')
usermod -aG docker $user
su -c 'mkdir $HOME/.ssh' - $user
su -c 'chmod 700 $HOME/.ssh' - $user
su -c 'echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2BMyRL1pvYi4JmAvsgimRQWouTehJw+dyw+LT4fGF9NQ4nVYreXDPhrjlIn7SF3RW9ynGT3unyoAj+ul0MGJYbFGGI8yPv/6f3mjego7BZQCf6OOVBQf8LDWy78KEKG7Yz5uwmrAaqszC+2C91bzG8MMEBmTm/XtUPNpwzCksaK0S7ZXQmaFThEAWGkV7vMmahBklOVUlFP0tUpxdP3SObBFFUNDgh37kP6SxrXpaLXUluGWtNoZvWsYzPkEqyZES8gJAmVg0ocqQfDnaxwiar8PQH/9prr5xDcjeFYmhTTO5hDHg5Zc9d359ZuYK4gAQ2VByongEFi1oxoJifUsJU1fFe56cd6YYn0G+8b49k+D1R5YK/n4JvoxciYOqTPGDmbDHBYKCwSlDNWh9uID/6PLrUE6NP6N/5YRJe5wawMZido+cmxRQQNjq7B5+YgQe5kSD49V1ruHWo8i18QCPDSjYFXdBTvwaQ/2AQSuBerGWkvVCtr/OJI47jj1x+50= eli@eli-Latitude-5590" >$HOME/.ssh/authorized_keys' - $user

# Run on one machine

[ -z $(hostname  | grep 'vm1$') ] && exit

count=$1
echo "Number of VM: '$count'"
publicIp1=$2
publicIp2=$3
publicIp3=$5
ip_array=($publicIp1 $publicIp2 $publicIp3)
echo ${ip_array[*]}

private1=`ssh -o "StrictHostKeyChecking no" vm@$publicIp1 /sbin/ip addr | grep 'inet 10.0' | awk '{print $2}' | cut -d'/' -f1`
private2=`ssh -o "StrictHostKeyChecking no" vm@$publicIp2 /sbin/ip addr | grep 'inet 10.0' | awk '{print $2}' | cut -d'/' -f1`
private3=`ssh -o "StrictHostKeyChecking no" vm@$publicIp3 /sbin/ip addr | grep 'inet 10.0' | awk '{print $2}' | cut -d'/' -f1`
#
#myIp=`ip addr  show eth0 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1`
#ip_pre=`echo $myIp | cut -d'.' -f1-3`
#i=3
#vm_list_ip=""
#
#while true; do
#	i=`expr $i + 1`
#	ip="$ip_pre.$i"
#	ping -c1 $ip
#	if [ $? = 0  ]; then
#		vm_list_ip="$vm_list_ip $ip"
#		count=`expr $count - 1`	
#		[ $count = 0 ] && break
#	fi
#	[ $i = 3 ] && break
#done
#
#[ $count -ne 0 ]&& exit 1
#echo $vm_list_ip
#
#file_name=cluster.yml
#echo "nodes:" > $file_name
#i=1
#for private in $vm_list_ip ; do
#  public
#	cat >> $file_name <<EOF
#   - address: $public
#    internal_address: $private
#    user: vm
#    role: [controlplane, worker, etcd]
#    hostname_override: linnovate-vm$i
#EOF
#	i=$((++i))
#done
#cat $file_name
#