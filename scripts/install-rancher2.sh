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
