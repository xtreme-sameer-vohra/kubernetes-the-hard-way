# Run End-to-End Tests

Install Go

```
wget https://dl.google.com/go/go1.18.linux-amd64.tar.gz

sudo tar -C /usr/local -xzf go1.18.linux-amd64.tar.gz
export GOPATH="/home/vagrant/go"
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
```

## Install kubetest

```
git clone --depth 1 https://github.com/kubernetes/test-infra.git
cd test-infra/
go build
```

> Note: it will take a long time to build as it has many dependencies.


## Use the version specific to your cluster

```
sudo apt install jq -y
K8S_VERSION=$(kubectl version -o json | jq -r '.serverVersion.gitVersion')
export KUBERNETES_CONFORMANCE_TEST=y
export KUBECONFIG="$HOME/.kube/config"

./kubetest --provider=skeleton --test --test_args=”--ginkgo.focus=\[Conformance\]” --extract ${K8S_VERSION} | tee test.out

```


This could take about 1.5 to 2 hours. The number of tests run and passed will be displayed at the end.

