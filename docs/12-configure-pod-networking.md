# Provisioning Pod Network

We chose to use CNI - [weave](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/) as our networking option.


### Deploy Weave Network

Deploy weave network. Run only once on the `master` node.


```bash
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

Weave uses POD CIDR of `10.32.0.0/12` by default.

## Verification

List the registered Kubernetes nodes from the master node:

```bash
kubectl get pods -n kube-system
```

> output

```
NAME              READY   STATUS    RESTARTS   AGE
weave-net-58j2j   2/2     Running   0          89s
weave-net-rr5dk   2/2     Running   0          89s
```

Reference: https://kubernetes.io/docs/tasks/administer-cluster/network-policy-provider/weave-network-policy/#install-the-weave-net-addon

Next: [Kube API Server to Kubelet Connectivity](13-kube-apiserver-to-kubelet.md)
