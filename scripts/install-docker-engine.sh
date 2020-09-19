apt update

apt -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properyies-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

apt fingerprint 0EBFCD88 

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt update

apt install -y docker-ce docker-ce-cli containerd.io