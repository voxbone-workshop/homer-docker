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

## Validating the install.

Let's try it with HEPgen.



## Exposing externally.

```
[centos@kube-master k8s]$ ifconfig | grep 192
        inet 192.168.122.227  netmask 255.255.255.0  broadcast 192.168.122.255

[centos@kube-master k8s]$ kubectl get svc
NAME                CLUSTER-IP       EXTERNAL-IP   PORT(S)     AGE
bootstrap           None             <none>        55555/TCP   18h
cron                None             <none>        55555/TCP   18h
glusterfs-cluster   10.107.176.131   <none>        1/TCP       23h
kamailio            10.97.100.89     <none>        9060/UDP    18h
kubernetes          10.96.0.1        <none>        443/TCP     12d
mysql               None             <none>        3306/TCP    18h
webapp              10.106.85.188    <none>        80/TCP      18h
[centos@kube-master k8s]$ kubectl get pods
NAME                        READY     STATUS    RESTARTS   AGE
cron-129834167-dcct9        1/1       Running   0          2h
kamailio-1707360978-3qpsd   1/1       Running   0          2h
mysql-2123826865-sxf5s      1/1       Running   0          2h
webapp-3460772183-4qj99     1/1       Running   0          2h

[centos@kube-master k8s]$ kubectl delete svc webapp
service "webapp" deleted
[centos@kube-master k8s]$ kubectl expose deployment webapp --port=80 --target-port=80 --external-ip 192.168.122.227
service "webapp" exposed
```

And in my case, tunnel it... since it's running on VMs "out in the ether"

    ssh root@192.168.1.119 -L 8080:192.168.122.227:80



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

