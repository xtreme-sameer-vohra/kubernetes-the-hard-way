# Bootstrapping the etcd Cluster

Kubernetes components are stateless and store cluster state in [etcd](https://github.com/coreos/etcd). In this lab you will bootstrap a two node etcd cluster and configure it for high availability and secure remote access.

## Prerequisites

The commands in this lab must be run on each controller instance: `master-1`, and `master-2`. Login to each of these using an SSH terminal.

You can perform this step with [tmux](01-prerequisites.md#running-commands-in-parallel-with-tmux)

## Bootstrapping an etcd Cluster Member

### Download and Install the etcd Binaries

Download the official etcd release binaries from the [coreos/etcd](https://github.com/coreos/etcd) GitHub project. As of Kubernetes 1.24, the etcd version is 3.5.3:

```bash
wget -q --show-progress --https-only --timestamping \
  "https://github.com/coreos/etcd/releases/download/v3.5.3/etcd-v3.5.3-linux-amd64.tar.gz"
```

Extract and install the `etcd` server and the `etcdctl` command line utility:

```bash
{
  tar -xvf etcd-v3.5.3-linux-amd64.tar.gz
  sudo mv etcd-v3.5.3-linux-amd64/etcd* /usr/local/bin/
}
```

### Configure the etcd Server

```bash
{
  sudo mkdir -p /etc/etcd /var/lib/etcd
  sudo cp ca.crt etcd-server.key etcd-server.crt /etc/etcd/
}
```

The instance internal IP address will be used to serve client requests and communicate with etcd cluster peers. Retrieve the internal IP addresses of the master(etcd) nodes:

```bash
INTERNAL_IP=$(ip addr show enp0s8 | grep "inet " | awk '{print $2}' | cut -d / -f 1)
MASTER_1=$(dig +short master-1)
MASTER_2=$(dig +short master-2)
```

Each etcd member must have a unique name within an etcd cluster. Set the etcd name to match the hostname of the current compute instance:

```bash
ETCD_NAME=$(hostname -s)
```

Create the `etcd.service` systemd unit file:
bash
```
cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --cert-file=/etc/etcd/etcd-server.crt \\
  --client-cert-auth=true \\
  --data-dir=/var/lib/etcd \\
  --experimental-initial-corrupt-check=true \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --initial-cluster=master-1=https://${MASTER_1}:2380,master-2=https://${MASTER_2}:2380 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster-state new \\
  --key-file=/etc/etcd/etcd-server.key \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --name ${ETCD_NAME} \\
  --peer-cert-file=/etc/etcd/etcd-server.crt \\
  --peer-client-cert-auth=true \\
  --peer-key-file=/etc/etcd/etcd-server.key \\
  --peer-trusted-ca-file=/etc/etcd/ca.crt \\
  --trusted-ca-file=/etc/etcd/ca.crt
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Start the etcd Server

```bash
{
  sudo systemctl daemon-reload
  sudo systemctl enable etcd
  sudo systemctl start etcd
}
```

> Remember to run the above commands on each controller node: `master-1`, and `master-2`.

## Verification

List the etcd cluster members:

```bash
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.crt \
  --cert=/etc/etcd/etcd-server.crt \
  --key=/etc/etcd/etcd-server.key
```

> output

```
1761bef04e125165, started, master-1, https://192.168.56.11:2380, https://192.168.56.11:2379, false
d60f170a453bcaf4, started, master-2, https://192.168.56.12:2380, https://192.168.56.12:2379, false
```

Reference: https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#starting-etcd-clusters

Prev: [Generating the Data Encryption Config and Key](06-data-encryption-keys.md)</br>
Next: [Bootstrapping the Kubernetes Control Plane](08-bootstrapping-kubernetes-controllers.md)
