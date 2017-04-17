# homer-k8s

Running Homer in Kubernetes.

## Running it (Currently WIP!)

Clone it (Currently based on k8s branch for Doug's PoC.)

```
git clone -b k8s https://github.com/dougbtv/homer-docker.git
cd homer-docker/k8s/
```

And then create from the given specs.

```
[centos@kube-master k8s]$ kubectl create -f persistent.yaml 
[centos@kube-master k8s]$ kubectl create -f deploy.yaml 
[centos@kube-master k8s]$ kubectl create -f service.yaml 
```

## Converting yaml with Kompose.

Installation in Fedora (also available in CentOS EPEL). Failed for Doug on first try. (kompose go app crashed)

```
sudo dnf -y install kompose
```

Or from source with:

```
sudo dnf install -y golang
mkdir /usr/src/gocode
export GOPATH=/usr/src/gocode
go get -u github.com/kubernetes-incubator/kompose
```

And run the convert...

```
$ pwd
~/homer-docker/k8s
$ /usr/src/gocode/bin/kompose -f ../docker-compose.yml convert
```

And concatenate them together to be nice...

```
$ for each in *persist*; do (cat $each && echo "---")>>pers.yaml; done
$ for each in *service*; do (cat $each && echo "---")>>serv.yaml; done
$ for each in *deploy*; do (cat $each && echo "---")>>depl.yaml; done
```

