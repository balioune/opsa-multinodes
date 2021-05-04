# https://www.cyberciti.biz/faq/how-to-install-kvm-on-centos-7-rhel-7-headless-server/
# https://www.itzgeek.com/how-tos/linux/centos-how-tos/install-kvm-qemu-on-centos-7-rhel-7.html

yum install -y qemu-kvm qemu-img virt-manager libvirt libvirt-python libvirt-client virt-install virt-viewer

yum install qemu-kvm libvirt libvirt-python libguestfs-tools virt-install


systemctl enable libvirtd
systemctl start libvirtd

# Install Open vSwitch
# https://gist.github.com/umardx/a31bf6a13600a55c0d07d4ca33133834

yum -y install wget openssl-devel gcc make python-devel openssl-devel kernel-devel graphviz kernel-debug-devel autoconf automake rpm-build redhat-rpm-config libtool python-twisted-core python-zope-interface PyQt4 desktop-file-utils libcap-ng-devel groff checkpolicy selinux-policy-devel

adduser ovs

su - ovs

mkdir -p ~/rpmbuild/SOURCES

wget http://openvswitch.org/releases/openvswitch-2.5.4.tar.gz

cp openvswitch-2.5.4.tar.gz ~/rpmbuild/SOURCES/

tar xfz openvswitch-2.5.4.tar.gz

rpmbuild -bb --nocheck openvswitch-2.5.4/rhel/openvswitch-fedora.spec

exit

yum localinstall /home/ovs/rpmbuild/RPMS/x86_64/openvswitch-2.5.4-1.el7.x86_64.rpm -y

# Finally start the openvswitch service and check that it’s running.

systemctl start openvswitch.service

# Make openvswitch service to start at boot time:

systemctl enable openvswitch
