#!/bin/bash
vm_master_client=$1
echo "VM is $vm_master_client"

apt update
apt install -y docker.io
systemctl enable docker
apt update 
apt install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt update
apt install -y kubelet kubeadm kubectl

#apt-mark hold kubelet kubeadm kubectl

# Create temporery user

temp_user=eli
temp_passwd=temp
useradd -m -d /home/$temp_user $temp_user
echo "$temp_passwd\n$temp_passwd" | passwd $temp_user

[ $vm_master_client = node ] && exit

# Master

user=$(grep ':x:1000:1000:' /etc/passwd | awk -F: '{print $1}')
user_id=1000
group_id=1000
user_home=$(grep ':x:1000:1000:' /etc/passwd | awk -F: '{print $6}')
masterIp=`ip addr  show eth0 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1`
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 | tee /tmp/join.temp
egrep 'kubeadm join|--discovery-token-ca-cert-hash' /tmp/join.temp > $user_home/join_to_kubernstes.sh
cp $user_home/join_to_kubernstes.sh /tmp
chmod 755 /tmp/join_to_kubernstes.sh

chown $user_id:$group_id /etc/kubernetes/admin.conf
# run as user  
cat > /tmp/install_master.sh<<'EOF'
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
EOF
su -c "bash /tmp/install_master.sh" - $user

myIp=`ip addr  show eth0 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1`
preIp=`echo $myIp | cut -d'.' -f1-3`
postIp=`echo $myIp | cut -d'.' -f4`
lastUp=`expr $postIp + 1`
lastDown=`expr $postIp - 1`
upIp="$preIp.$lastUp"
downIp="$preIp.$lastDown"
i=5
while true; do
	ping -c1 $upIp
	if [ $? = 0  ]; then
		vm2=$upIp
		break
	fi
	ping -c1 $downIp
	if [ $? = 0  ]; then
                vm2=$downIp
                break
	fi
	i=`expr $i - 1`
	[ $i = 0 ] && break
done
if [ -z $vm2 ]; then
        echo "No ping to other machine"
		exit 1
fi

cat > /tmp/install_key.sh<<'EOF'
ssh-keygen -q -t rsa -N '' <<< ""$'\n'"y" 2>&1 >/tmp/install_k8s_client
EOF

apt update
apt install -y sshpass

cat > /tmp/install_k8s_client.sh<<EOF
{
sshpass -p "$temp_passwd" ssh-copy-id $vm2
scp /tmp/join_to_kubernstes.sh $temp_user@$vm2
ssh $temp_user@$vm2 "bash join_to_kubernstes.sh"
ssh $temp_user@$vm2 "userdel $temp_user" 
} 2>&1 | tee -a /tmp/install_k8s_client.log
EOF

chmod 755 /tmp/install_key.sh /tmp/install_k8s_client.sh

su -c "bash /tmp/install_key.sh" - $temp_user
su -c "bash /tmp/install_k8s_client.sh" - $temp_user
userdel $temp_user
