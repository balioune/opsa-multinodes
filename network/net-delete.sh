#!/bin/bash


# Take one argument from the commandline: VM name
if ! [ $# -eq 1 ]; then
    echo "Usage: $0 <node-name>"
    exit 1
fi

POOL=nfv
POOL_PATH=/home/nfv

IMG_NAME=ubuntu-14.04-server-cloudimg-amd64-disk1.img

SERVER_NAME=$1

sudo virsh destroy $SERVER_NAME
sudo virsh undefine $SERVER_NAME

sudo rm /home/nfv/$SERVER_NAME.img
sudo rm /home/nfv/$SERVER_NAME.iso


sudo virsh pool-refresh $POOL

clear

sudo virsh vol-list --pool $POOL
