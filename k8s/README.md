# homer-k8s

Running Homer in Kubernetes.

## Converting yaml with Kompose.

Installation in Fedora (also available in CentOS EPEL)

```
sudo dnf -y install kompose
```

Or from source with

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

