echo "Deleting External HA network"
./net-delete.sh externalha

echo "Deleting Internal HA network"
./net-delete.sh internalha

echo "Deleting hostconnect network"
./net-delete.sh hostconnect

