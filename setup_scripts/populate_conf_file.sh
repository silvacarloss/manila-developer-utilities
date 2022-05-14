#!/bin/bash

DEST=${DEST:-/opt/stack}
MANILACLIENT_DIR=${MANILACLIENT_DIR:-$DEST/python-manilaclient}
MANILACLIENT_CONF="$MANILACLIENT_DIR/etc/manilaclient/manilaclient.conf"
# Go to the manilaclient dir
cd $MANILACLIENT_DIR
# Give permissions
sudo chown -R $USER:stack .
# Create manilaclient config file
touch $MANILACLIENT_CONF
# Import functions from devstack
source $HOME/devstack/functions
# Set options to config client.
source $HOME/devstack/openrc demo demo
export OS_TENANT_NAME=${OS_PROJECT_NAME:-$OS_TENANT_NAME}
iniset $MANILACLIENT_CONF DEFAULT username $OS_USERNAME
iniset $MANILACLIENT_CONF DEFAULT tenant_name $OS_TENANT_NAME
iniset $MANILACLIENT_CONF DEFAULT password $OS_PASSWORD
iniset $MANILACLIENT_CONF DEFAULT auth_url $OS_AUTH_URL
iniset $MANILACLIENT_CONF DEFAULT project_domain_name $OS_PROJECT_DOMAIN_NAME
iniset $MANILACLIENT_CONF DEFAULT user_domain_name $OS_USER_DOMAIN_NAME
iniset $MANILACLIENT_CONF DEFAULT project_domain_id $OS_PROJECT_DOMAIN_ID
iniset $MANILACLIENT_CONF DEFAULT user_domain_id $OS_USER_DOMAIN_ID
source $HOME/devstack/openrc admin demo
export OS_TENANT_NAME=${OS_PROJECT_NAME:-$OS_TENANT_NAME}
iniset $MANILACLIENT_CONF DEFAULT admin_username $OS_USERNAME
iniset $MANILACLIENT_CONF DEFAULT admin_tenant_name $OS_TENANT_NAME
iniset $MANILACLIENT_CONF DEFAULT admin_password $OS_PASSWORD
iniset $MANILACLIENT_CONF DEFAULT admin_auth_url $OS_AUTH_URL
iniset $MANILACLIENT_CONF DEFAULT admin_project_domain_name $OS_PROJECT_DOMAIN_NAME
iniset $MANILACLIENT_CONF DEFAULT admin_user_domain_name $OS_USER_DOMAIN_NAME
iniset $MANILACLIENT_CONF DEFAULT admin_project_domain_id $OS_PROJECT_DOMAIN_ID
iniset $MANILACLIENT_CONF DEFAULT admin_user_domain_id $OS_USER_DOMAIN_ID
# Suppress errors in cleanup of resources
SUPPRESS_ERRORS=${SUPPRESS_ERRORS_IN_CLEANUP:-False}
iniset $MANILACLIENT_CONF DEFAULT suppress_errors_in_cleanup $SUPPRESS_ERRORS
# Set access type usage specific to dummy driver that we are using in CI
iniset $MANILACLIENT_CONF DEFAULT access_types_mapping "nfs:ip,cifs:user"
# Dummy driver is capable of running share migration tests
iniset $MANILACLIENT_CONF DEFAULT run_migration_tests "True"
# Running mountable snapshot tests in dummy driver
iniset $MANILACLIENT_CONF DEFAULT run_mount_snapshot_tests "True"
# Create share network and use it for functional tests if required
USE_SHARE_NETWORK=$(trueorfalse True USE_SHARE_NETWORK)

if [[ ${USE_SHARE_NETWORK} = True ]]; then
    SHARE_NETWORK_NAME=${SHARE_NETWORK_NAME:-ci}
    DEFAULT_NEUTRON_NET=$(openstack network show private -c id -f value)
    DEFAULT_NEUTRON_SUBNET=$(openstack subnet show private-subnet -c id -f value)
    NEUTRON_NET=${NEUTRON_NET:-$DEFAULT_NEUTRON_NET}
    NEUTRON_SUBNET=${NEUTRON_SUBNET:-$DEFAULT_NEUTRON_SUBNET}
    manila share-network-create --name $SHARE_NETWORK_NAME --neutron-net $NEUTRON_NET --neutron-subnet $NEUTRON_SUBNET
    iniset $MANILACLIENT_CONF DEFAULT share_network $SHARE_NETWORK_NAME
    iniset $MANILACLIENT_CONF DEFAULT admin_share_network $SHARE_NETWORK_NAME

fi

# Set share type if required
if [[ "$SHARE_TYPE" ]]; then
    iniset $MANILACLIENT_CONF DEFAULT share_type $SHARE_TYPE

fi
