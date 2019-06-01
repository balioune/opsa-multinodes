#!/bin/bash

NETNAME=$1

function create_kvm_ovs_net()
{
  # create OVS bridge. 
  # parameter net-name
  sudo ovs-vsctl add-br br-$1
  net_xml="<network>
    <name>$1</name>
    <forward mode='bridge'/>
    <bridge name='br-$1'/>
    <virtualport type='openvswitch'>
    </virtualport>
  </network>"
  cat > network.xml <<EOF
$net_xml
EOF

  sudo virsh net-define network.xml
  sudo virsh net-start $1

  sudo rm network.xml 
}

## Public network rules
#sudo iptables -A FORWARD --dst 192.168.1.0/24 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
#sudo iptables -A FORWARD --src 192.168.1.0/24 -j ACCEPT
#sudo iptables -t nat  -A POSTROUTING --src 192.168.1.0/24 -o eth0 -j SNAT --to 37.187.88.196


create_kvm_ovs_net $NETNAME

