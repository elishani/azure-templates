#!/bin/bash

echo
echo "Parameters list: $@"
echo "_________________________________________________________________________________________"
apt update

# Install doker engine
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce docker-ce-cli containerd.io

apt-get update
apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

user_name=$1
user_phone=$2
usere_mail=$3
shift;shift;shift

user=$1
shift
echo "user='$user'"
home=$(grep "^$user:" /etc/passwd | awk -F: '{print $6}')
owner=$(grep "^$user:" /etc/passwd | grep "^$user:" /etc/passwd | awk -F: '{print $3,":",$4}' | sed 's/ //g')
usermod -aG docker $user

user_file=user_information.txt
echo "User Name: '$user_name'" > $user_file
echo "User Phone: '$user_phone'" >> $user_file
echo "User Email: '$usere_mail'" >> $user_file
cp $user_file $home
cat $user_file

ip_loadbalancer=$1
echo "IP loadbalancer: '$ip_loadbalancer'" > $home/loadbalancerIP.txt
cat $home/loadbalancerIP.txt
chown $owner $home/loadbalancerIP.txt
cat $home/loadbalancerIP.txt
shift

ssh_rsa="$1"
ssh_rsa_pub="$2"
shift;shift

echo $ssh_rsa_pub | tr '%' ' ' > $home/.ssh/authorized_keys
chown -R $owner $home/.ssh
chmod  600 $home/.ssh/*

# RUN ONLY ON ONE MACHINE

[ -z $(hostname  | grep 'vm1$') ] && exit

fqdn=$1
echo "fqdn='$fqdn'"
echo "$ip_loadbalancer $fqdn" >> /etc/hosts
shift

count=$1
count=$((++count))
shift

ipp=()
ipv=()
host=()
ipp[0]=$1
ipv[0]=$2
host[0]=$3
if [ ! -z "$4" ];then
  ipp[1]=$4
  ipv[1]=$5
  host[1]=$6
fi
if [ ! -z "$7" ];then
  ipp[2]=$7
  ipv[2]=$8
  host[2]=$9
fi

echo "Public IPs"
echo "${ipp[@]}"

echo "Private Ips"
echo "${ipv[@]}"

echo "Hosts List"
echo "${host[@]}"

file_name=cluster.yml
echo "nodes:" > $file_name
i=0
for public_ip in "${ipp[@]}"
do
  private_ip=${ipv[$i]}
  hostname=${host[$i]}
  cat >> $file_name <<EOF
  - address: $public_ip
    internal_address: $private_ip
    user: vm
    role: [controlplane, worker, etcd]
    hostname_override: $hostname
EOF
  i=$((++i))
done

cp $file_name $home
cat $file_name
chown $owner $home/$filename

cd /usr/local/bin
wget https://github.com/rancher/rke/releases/download/v1.2.0-rc15/rke_linux-amd64
mv rke_linux-amd64 rke
chmod +x rke
rke --version
echo $ssh_rsa | tr '%' ' ' | tr '@' '\n' > $home/.ssh/id_rsa
echo $ssh_rsa_pub | tr '%' ' ' > $home/.ssh/id_rsa.pub
chown -R $owner $home/.ssh
chmod -R 600 $home/.ssh/*

snap install helm3
helm3 version

echo "***RUN: $home/run_rke.sh as user '$user'"

cat > $home/run_rke.sh <<'EOF'
#!/bin/bash

u=$(id | grep root | awk -F'=' '{print $1}')
if [ ! -z $u ]; then
  echo "Can't be run as root"
  exit 1
fi

echo y | rke remove
rke up
[ ! -d .kube ] && mkdir .kube
cp kube_config_cluster.yml .kube/config
export KUBECONFIG=./kube_config_cluster.yml
kubectl get nodes

helm3 repo add rancher-latest https://releases.rancher.com/server-charts/latest
kubectl create namespace cattle-system
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.0/cert-manager.crds.yaml
kubectl create namespace cert-manager
helm3 repo add jetstack https://charts.jetstack.io
helm3 repo update
helm3 install cert-manager jetstack/cert-manager --namespace cert-manager --version v0.15.0
echo "Sleeping for 15 secondes"
sleep 15
kubectl get pods --namespace cert-manager
helm3 install rancher rancher-latest/rancher --namespace cattle-system --set hostname=$fqdn

echo "End of story"
EOF
cd $home 
su -c "bash -xv run_rke.sh" - $user