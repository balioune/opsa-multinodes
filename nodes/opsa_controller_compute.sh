#!/bin/bash

# Take one argument from the commandline: VM name
if ! [ $# -eq 2 ]; then
    echo "Usage: $0 <server-namer> <RAM in MB>"
    exit 1
fi

POOL=nfv
POOL_PATH=/nfv

IMG_NAME=ubuntu-18.04-server-cloudimg-amd64.img
#IMG_NAME=ubuntu-16.04-server-cloudimg-amd64-disk1.img
SERVER_NAME=$1
RAM=$2

## Clone disk for the new server
sudo virsh vol-clone --pool ${POOL} ${IMG_NAME} ${SERVER_NAME}.img

sudo qemu-img resize /nfv/${SERVER_NAME}.img +100G

# Create disk
sudo qemu-img create -f raw ${POOL_PATH}/${SERVER_NAME}-disk1 150
# sudo qemu-img create -f raw ${POOL_PATH}/${SERVER_NAME}-disk2 80
# sudo qemu-img create -f raw ${POOL_PATH}/${SERVER_NAME}-disk3 80

sudo qemu-img resize /nfv/${SERVER_NAME}-disk1  +150G
#sudo qemu-img resize /nfv/${SERVER_NAME}-disk2 +50G
#sudo qemu-img resize /nfv/${SERVER_NAME}-disk3 +50G
## SERVER

METADATA="instance-id: iid-${SERVER_NAME};
network-interfaces: |
  auto ens3
  iface ens3 inet dhcp
hostname: ${SERVER_NAME}
local-hostname: ${SERVER_NAME}
ssh_authorized_keys:
   - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmUqNtiJdPrw3+GPGFBE4GZBTHtx+Z68I/EVbljF9frbQ7wUZdWue8VSQfPw0X+NexXzwhzBrfOtZrqe51oSJX6TK3+VjB9Ht+xvW/WWOqvGzhFNmi5lRgxB6VmUHXl+Qul18dRDXg8+kA1Zx4vHSTBf34rg1OtKxmZbzLTrzq1RzwVaYNLvTp/2k9fVmeHnVdNUQLR//O+xI2eOAJud/OLtoWYu1VaBqWQfv18aBWGU4bGAonUKejk+zpHa3YBP3aKKjpDA1DejFDFzmFIdDTUNhcKPgbb8XBXaAYva0hHA16Ct6yHqYcvKCpxK9e/F75XvolYGGAKeAi/vP7oy6p root@ns3342362"


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
  --network network=default  --network network=public  --network network=data \
  --disk vol=${POOL}/${SERVER_NAME}.img,format=qcow2,bus=virtio \
  --disk vol=${POOL}/${SERVER_NAME}.iso,bus=virtio \
  --disk vol=${POOL}/${SERVER_NAME}-disk1,format=qcow2,bus=virtio
