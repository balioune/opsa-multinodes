# Install KVM

# Determine if your server is capable of running hardware accelerated KVM virtual machines
sudo apt install cpu-checker -y

# install KVM packages 
sudo apt install qemu qemu-kvm libvirt-bin  bridge-utils  virt-manager -y

# Restart service
sudo service libvirtd start


# Install Open vSwitch
sudo apt-get install openvswitch-switch -y
