apt-get update

export LC_ALL=C

git clone https://git.openstack.org/openstack/openstack-ansible \
    /opt/openstack-ansible


cd /opt/openstack-ansible

git checkout 16.0.27

nohup scripts/bootstrap-ansible.sh > /bootstrap-ansible.log
nohup scripts/bootstrap-aio.sh > /bootstrap-aio.log

cd /opt/openstack-ansible/

cp etc/openstack_deploy/conf.d/{aodh,gnocchi,ceilometer}.yml.aio /etc/openstack_deploy/conf.d/
for f in $(ls -1 /etc/openstack_deploy/conf.d/*.aio); do mv -v ${f} ${f%.*}; done

cd /opt/openstack-ansible/playbooks


nohup openstack-ansible setup-hosts.yml > /setup-hosts.log
nohup openstack-ansible setup-infrastructure.yml > /setup-infrastructure.log
nohup openstack-ansible setup-openstack.yml > /setup-openstack.log
