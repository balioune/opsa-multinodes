#!/bin/bash

# Take one argument from the commandline: VM name
if ! [ $# -eq 2 ]; then
    echo "Usage: $0 <server-namer> <RAM in MB>"
    exit 1
fi

POOL=nfv
POOL_PATH=/openstack

IMG_NAME=ubuntu-16.04-server-cloudimg-amd64-disk1.img

SERVER_NAME=$1
RAM=$2

## Clone disk for the new server
sudo virsh vol-clone --pool ${POOL} ${IMG_NAME} ${SERVER_NAME}.img

sudo qemu-img resize /openstack/${SERVER_NAME}.img +100G

## SERVER

METADATA="instance-id: iid-${SERVER_NAME};
network-interfaces: |
  auto ens3
  iface ens3 inet dhcp
  auto ens4
  iface ens4 inet static
  address 192.168.1.15
  netmask 255.255.255.0
  auto ens5
  iface ens5 inet static
  address 192.168.2.15
  netmask 255.255.255.0

hostname: ${SERVER_NAME}
local-hostname: ${SERVER_NAME}
ssh_authorized_keys:
   - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC729xMo967OoQea0/Hh3iaFlzijVntj5eVsMRJGROIt5gpHIEDEZ31V6Kz0AYcGyVlF7l6lZhUGE2clTlAFeTkpIZ1rRlnJI8dKyJS2uUzXsIdUWCDejpWqQNe3KXnC7szeolry+5pgmzVigmdzYqHkWdIy8m2a0JQ3z/eynQ6bgXaaYW19ZK1dZERImFiXb3jMvYkHPCjKvuV+Aq1PMBC6gt/Yb4mPjeN05QAwlJ8cEFuYC0X+HUgT5J14njcpoWV4mhSc3MPZEZO5DMn8F2PKZFgQHjfvLnzyAAV1BXNALOBBYBAODYlSehT5vwrPZhJE7HFtF+wam9a2p6tx1Dn ubuntuesgi@ubuntu1"


USERDATA="#cloud-config

password: password
chpasswd: { expire: False }
ssh_pwauth: True
"

function create_metadata()
{
  cat > meta-data <<EOF
$METADATA
EOF
}


function create_userdata()
{
  cat > user-data <<EOF
$USERDATA
EOF

}

create_metadata
create_userdata
sudo genisoimage -output $SERVER_NAME.iso -volid cidata -joliet -rock user-data meta-data
sudo mv $SERVER_NAME.iso $POOL_PATH
rm -rf meta-data  user-data

sudo virsh pool-refresh $POOL

sudo virt-install -r $RAM     \
  -n $SERVER_NAME     \
  --vcpus=5    \
  --memballoon virtio    \
  --boot hd     \
  --network network=default --network network=externalha --network network=internalha --network network=hostconnect\
  --disk vol=${POOL}/${SERVER_NAME}.img,format=qcow2,bus=virtio \
  --disk vol=${POOL}/${SERVER_NAME}.iso,bus=virtio 
