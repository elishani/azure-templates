#!/bin/bash
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

# Master
masterIp=`ip addr  show eth0 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1`
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 | tee /tmp/join.temp
egrep 'kubeadm join|--discovery-token-ca-cert-hash' /tmp/join.temp > $HOME/join_to_kubernstes.sh
user=$(grep ':x:1000:1000:' /etc/passwd | awk -F: '{print $1}')
user_id=1000
group_id=1000
chown $user_id:$group_id /etc/kubernetes/admin.conf
# run as user  
cat > /tmp/install.sh<<'EOF'
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
EOF
su -c "bash /tmp/install.sh" - $user
