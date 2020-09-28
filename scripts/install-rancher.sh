#!/bin/bash

apt update

# Install doker engine
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce docker-ce-cli containerd.io

user=$1
shift
echo "user='$user'"
home=$(grep "^$user:" /etc/passwd | awk -F: '{print $6}')
owner=$(grep "^$user:" /etc/passwd | grep "^$user:" /etc/passwd | awk -F: '{print $3,":",$4}' | sed 's/ //g')
usermod -aG docker $user
#mkdir $home/.ssh
#chown -R $owner $home/.ssh
#chmod 600 $home/.ssh
ssh_rsa="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBAcK82Xtg0pMnLacGyHnZFQbnER7HSPMS7++hT3Z4DJVsApCN/1QHkzwHFSe/VqOYJtRx9pN3Por3PjeOU/skb76p0AEsfj+qfA1rdlcVkh9AmNpVYk2KpSUfN4B5dnHSjRBeHNmuvYTbpid9NHPdt/JM9srlFXk66p9ljg19iAca7uEbAn6y9j46xYUCWzJI6Deai+x/ecpdpH3FiJ6AQhrE1jiOT8bMm9lcpjeaEZbGPGmHQYBt7Z9quSa57JL+NUgURY9PitbsdRxqqvxDbjSdxXzFu9UUOzet7aqcEEyDOADTtj8Ot/v5WpvZchGQSfAt1NCCeuvk6h3ISuhx"
echo "$ssh_rsa" > $home/.ssh/authorized_keys
#chown -R $owner $home/.ssh
#chmod -R 600 $home/.ssh

# Run on one machine

[ -z $(hostname  | grep 'vm0$') ] && exit

count=$1
count=$((++count))
shift
ipp0=$1
ipv0=$2
host=$3
echo "MV: $host $ipp0 $ipv0"
shift;shift;shift

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

echo "Public ip"
echo "${ipp[@]}"

echo "Private ip"
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
chown $owner $home/$filename

cd /usr/local/bin
wget https://github.com/rancher/rke/releases/download/v1.2.0-rc15/rke_linux-amd64
mv rke_linux-amd64 rke
chmod +x rke
rke --version
echo "$ssh_rsa" > $home/.ssh/id_rsa
echo "-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAwQHCvNl7YNKTJy2nBsh52RUG5xEex0jzEu/voU92eAyVbAKQ
jf9UB5M8BxUnv1ajmCbUcfaTdz6K9z43jlP7JG++qdABLH4/qnwNa3ZXFZIfQJja
VWJNiqUlHzeAeXZx0o0QXhzZrr2E26YnfTRz3bfyTPbK5RV5OuqfZY4NfYgHGu7h
GwJ+svY+OsWFAlsySOg3movsf3nKXaR9xYiegEIaxNY4jk/GzJvZXKY3mhGWxjxp
h0GAbe2farkmueyS/jVIFEWPT4rW7HUcaqr8Q240ncV8xbvVFDs3re2qnBBMgzgA
07Y/Drf7+Vqb2XIRkEnwLdTQgnrr5OodyErocQIDAQABAoIBABdTDyWjYrWgvQfP
DJBVSeRiFiN2fjG3LyjqthrYb4iyfJxA8xc19AG2WVrBw7vrzHlmt+XN1qRieojG
jBA3NfKBTplW+c1WtHr14ulJs9x3fC9iSYBoENbgfkv3eR80oSzAv2mgMu5bGOMy
gTMwU5BH2pBSgtKMdcoY8IplUFwLDo9zAxob07xs4x1VRvfPbJViNdHnbQjvuDmL
A6EMX4ZV0Uo6G6F/JZD6gX8taBxaAbXnBy/9tndZqjz1ADbqRRMMNJq9BcDtREVl
75ZvEOicuemyntX1OP+AChEziZFDm/H0l3N/3hwqszmnCclk+J06mLM6CuSPIWYK
/g8DrcECgYEA5cUDALWMEVkh2WWiw64psyk+iFJjB9t2BB1OBL6umbCN8XS67lmN
0I6n8rB+XlLglzvSW6Q9tXjevSHtaeQDB66gwMmzh/GKEiNas74qJtBFeAmFS2ac
PP/5TWsMjEdLrjM6AHaoqeIBOh0A3DQSe9EAvfDeXdait0o8PXHmQV8CgYEA1wpd
DgAhrj9vCwgQg+EsszPfG8FEVmggstEKijiAAywa1QMyX41c4pXenfSYW0o52k6o
NXtsDYI95SxgQeF35WKslpT9lafcZg6XZz1a18mabsuzPw7Uo03jewd7Z51DampZ
wQHLVSxt2w+8atDbH8LNZor3iwYGjvEp3W2cGC8CgYEAqustu6ZRBkqmemA3fpac
4HBq2t9mWV7wYEkoUzFBEoSaYiXyNAGcE6s61bZimmnONdHDPnZjjQ3XqxuEzwNV
Ga7WV/LywMp1ad6wxwpLssm1E4EJjbhLurizS9q439TdQD1NBTE/b/f177PJgwSd
R0uG4MQ/tdBHBE+NliuXG8MCgYAxCnoCUWFc/bZzS5mImfe5vqCpEcBl/EVIwoem
0g/PqWVNIvd/9xsxyYAFgdylJR5gfQO7frQ7uHIpK5+gJq1TMNevV7clRCztUXKR
5toq0B1aGzZ7sQQpYf/49NHd5W2UfUCO1bvrZsB+7u3HZm4yphh1xEeD+xHP04v6
pZ6tnQKBgC4/kqwrLlvdeG3+B8cbIQcCU4IX9nNWUcf8Urhbq9wExFTGPruVmcVT
vyUrmcLZg9/ztlJGgOg9bXijO5PlR7X2PE0FjHk7CQq/+QKkaDBpJiY0LfW2zV3P
x8bswqHNdQF5Jy+Bt4QCfrVFaxnqsZgY2z3Dr7dtFo3aKy5N1zcs
-----END RSA PRIVATE KEY-----
" > $home/.ssh/id_rsa
#chown -R $owner $home/.ssh
#chmod -R 600 $home/.ssh
cd $home
rke up

cp kube_config_cluster.yml .kube/config
export KUBECONFIG=./kube_config_cluster.yml
kubectl get nodes
