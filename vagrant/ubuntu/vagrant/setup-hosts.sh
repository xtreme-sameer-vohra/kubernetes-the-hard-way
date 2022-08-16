#!/bin/bash
#
# Set up /etc/hosts so we can resolve all the machines in the VirtualBox network
set -ex
IFNAME=$1
THISHOST=$2
ADDRESS="$(ip -4 addr show $IFNAME | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
sed -e "s/^.*${HOSTNAME}.*/${ADDRESS} ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts

# remove ubuntu-jammy entry
sed -e '/^.*ubuntu-jammy.*/d' -i /etc/hosts
sed -e "/^.*$2.*/d" -i /etc/hosts

# Update /etc/hosts about other hosts
cat >> /etc/hosts <<EOF
192.168.56.11  master-1
192.168.56.12  master-2
192.168.56.21  worker-1
192.168.56.22  worker-2
192.168.56.30  loadbalancer
EOF
