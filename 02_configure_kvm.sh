#!/bin/bash

sudo mkdir /openstack
POOL=nfv
POOL_PATH=/openstack

##Create pool of volumes that will be allowated to KVM VNF
sudo virsh pool-define-as --name ${POOL} --type dir --target ${POOL_PATH}
sudo virsh pool-autostart ${POOL}
sudo virsh pool-build ${POOL}
sudo virsh pool-start ${POOL}

cd $POOL_PATH
wget https://cloud-images.ubuntu.com/releases/16.04/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img

sudo virsh pool-refresh $POOL

sudo virsh vol-list --pool $POOL

