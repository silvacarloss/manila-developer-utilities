#!/bin/bash

# Make sure you have loaded your openstack credentials before actually
# running this script. This script is useful in case your tempest tests
# are failing in a local environment, and it left a lot of garbage.
# Recommended to source this script in your environment and use the
# functions you want to use. In case you want an entire cleanup, just
# run `remove_all_tempest_networking_garbage` in your terminal.
# Cheers! :)

function remove_tempest_ports {
   declare -a router_ids=$(openstack router list | grep tempest | cut -d '|' -f2)

   echo "Starting to remove tempest ports..."
   for router_id in ${router_ids[@]}; do
      echo "Listing ports for router $router_id"
      ports=$(openstack port list --router $router_id | cut -d '"' -f2)

      for port in ${ports[@]}; do
          echo "Removing port $port from router $router_id ..."
          openstack router remove port $router_id $port
      done
   done
}

function remove_tempest_routers {
   declare -a router_ids=$(openstack router list | grep tempest | cut -d '|' -f2)

   echo "Starting to delete tempest routers..."
   for router_id in ${router_ids[@]}; do
      echo "Deleting tempest router $router_id ..."
      openstack router delete $router_id
   done
}

function remove_tempest_subnets {
   declare -a subnet_ids=$(openstack subnet list | grep tempest | cut -d '|' -f2)

   echo "Starting to remove subnets..."
   for subnet_id in ${subnet_ids[@]}; do
      echo "Removing subnet $subnet_id ..."
      openstack subnet delete $subnet_id
   done

}

function remove_tempest_networks {
   declare -a network_ids=$(openstack network list | grep tempest | cut -d '|' -f2)

   echo "Starting to remove networks..."
   for network_id in ${network_ids[@]}; do
      echo "Removing network $network_id ..."
      openstack network delete $network_id
   done
}

function remove_all_tempest_networking_garbage {
   remove_tempest_ports
   remove_tempest_routers
   remove_tempest_subnets
   remove_tempest_networks
}