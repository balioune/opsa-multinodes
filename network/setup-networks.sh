echo "Creating External HA network"
./net-create.sh externalha
virsh net-autostart externalha

echo "Creating Internal HA network"
./net-create.sh internalha
virsh net-autostart internalha

echo "Creating hostconnect network"
./net-create.sh hostconnect
virsh net-autostart hostconnect
