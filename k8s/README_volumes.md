# Persistent volumes

This is the crux of the situation, I think.

# So, persistent volumes.

* [simple minikube example with hostpath, from kube](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/)

Minikube.... for chumps. We want a cluster, and host volumes are a temporary work-around for something better. Let's continue on...

# Add storage to a guest with virsh

* [from access.redhat.com](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Virtualization_Administration_Guide/sect-Virtualization-Virtualized_block_devices-Adding_storage_devices_to_guests.html)

# Using Gluster.

* [gluster on centos](https://wiki.centos.org/HowTos/GlusterFSonCentOS)
* [blog article from gluster about it](http://blog.gluster.org/2016/03/persistent-volume-and-claim-in-openshift-and-kubernetes-using-glusterfs-volume-plugin/)

# Putting it to work in kube

* [The kube examples](https://github.com/kubernetes/kubernetes/tree/master/examples/volumes/glusterfs)

## Example usage of gluster with k8s

Run kubernetes playbook, then... apply the glusterfs playbooks.

```
ansible-playbook -i inventory/vms.inventory gluster-install.yml
```

Then, create a pod...

```
{
    "apiVersion": "v1",
    "kind": "Pod",
    "metadata": {
        "name": "dougglusterfs"
    },
    "spec": {
    "containers": [
            {
                "name": "glusterfs",
                "image": "centos:centos7",
                "command": ["/bin/bash"],
                "args": ["-c", "while true; do sleep 10; done"],
                "volumeMounts": [
                    {
                        "mountPath": "/mnt/glusterfs",
                        "name": "glusterfsvol"
                    }
                ]
            }
    ],
    "volumes": [
            {
                "name": "glusterfsvol",
                "glusterfs": {
                    "endpoints": "glusterfs-cluster",
                    "path": "glustervol1",
                    "readOnly": false
                }
            }
    ]
    }
}
```

And you can see it uses the volume as created.

## And a persistent volume claim.

[This yaml generally borrowed from gluster.org doc](http://blog.gluster.org/2016/03/persistent-volume-and-claim-in-openshift-and-kubernetes-using-glusterfs-volume-plugin/).

In `~/gluster-pv.yaml` set:

```
apiVersion: "v1"
kind: "PersistentVolume"
metadata:
  name: "gluster-default-volume"
spec:
  capacity:
    storage: "1850Mi"
  persistentVolumeReclaimPolicy: "Recycle"
  accessModes:
    - "ReadWriteMany"
  glusterfs:
    endpoints: "glusterfs-cluster"
    path: "glustervol1"
    readOnly: false
```

Then create one...

```
[centos@kube-master ~]$ kubectl create -f gluster-pv.yaml 
persistentvolume "gluster-default-volume" created
[centos@kube-master ~]$ 
[centos@kube-master ~]$ 
[centos@kube-master ~]$ 
[centos@kube-master ~]$ kubectl get pv
NAME                     CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS      CLAIM     STORAGECLASS   REASON    AGE
gluster-default-volume   1850Mi     RWX           Recycle         Available                                      3s
```

And there you go, right?

So, let's use that.

## Trying again, with more volumes....

So, yeah, you need multiple volumes for multiple claims, appears.

Let's make a bigger set of PV's...

```yaml
apiVersion: "v1"
kind: "PersistentVolume"
metadata:
  name: "gluster-volume-1"
spec:
  capacity:
    storage: "600Mi"
  persistentVolumeReclaimPolicy: "Recycle"
  accessModes:
    - "ReadWriteMany"
  glusterfs:
    endpoints: "glusterfs-cluster"
    path: "glustervol1"
    readOnly: false
---
apiVersion: "v1"
kind: "PersistentVolume"
metadata:
  name: "gluster-volume-2"
spec:
  capacity:
    storage: "300Mi"
  persistentVolumeReclaimPolicy: "Recycle"
  accessModes:
    - "ReadWriteMany"
  glusterfs:
    endpoints: "glusterfs-cluster"
    path: "glustervol1"
    readOnly: false
---
apiVersion: "v1"
kind: "PersistentVolume"
metadata:
  name: "gluster-volume-3"
spec:
  capacity:
    storage: "300Mi"
  persistentVolumeReclaimPolicy: "Recycle"
  accessModes:
    - "ReadWriteMany"
  glusterfs:
    endpoints: "glusterfs-cluster"
    path: "glustervol1"
    readOnly: false
---
apiVersion: "v1"
kind: "PersistentVolume"
metadata:
  name: "gluster-volume-4"
spec:
  capacity:
    storage: "100Mi"
  persistentVolumeReclaimPolicy: "Recycle"
  accessModes:
    - "ReadWriteMany"
  glusterfs:
    endpoints: "glusterfs-cluster"
    path: "glustervol1"
    readOnly: false
---
apiVersion: "v1"
kind: "PersistentVolume"
metadata:
  name: "gluster-volume-5"
spec:
  capacity:
    storage: "100Mi"
  persistentVolumeReclaimPolicy: "Recycle"
  accessModes:
    - "ReadWriteMany"
  glusterfs:
    endpoints: "glusterfs-cluster"
    path: "glustervol1"
    readOnly: false
---
```

This looks at least better to start....


```
[centos@kube-master ~]$ kubectl create -f gluster-pv.yaml 
persistentvolume "gluster-volume-1" created
persistentvolume "gluster-volume-2" created
persistentvolume "gluster-volume-3" created
persistentvolume "gluster-volume-4" created
persistentvolume "gluster-volume-5" created
[centos@kube-master ~]$ watch -n1 kubectl get pv
[centos@kube-master ~]$ kubectl get pv
NAME               CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS      CLAIM     STORAGECLASS   REASON    AGE
gluster-volume-1   600Mi      RWX           Recycle         Available                                      10s
gluster-volume-2   300Mi      RWX           Recycle         Available                                      10s
gluster-volume-3   300Mi      RWX           Recycle         Available                                      10s
gluster-volume-4   100Mi      RWX           Recycle         Available                                      9s
gluster-volume-5   100Mi      RWX           Recycle         Available                                      9s
```

## With a bunch of volumes available, can we fire up the Homer persistent volume claims?

```
[centos@kube-master k8s]$ kubectl create -f persistent.yaml 
persistentvolumeclaim "homer-data-dashboard" created
persistentvolumeclaim "homer-data-mysql" created
persistentvolumeclaim "homer-data-semaphore" created
[centos@kube-master k8s]$ kubectl get pvc
NAME                   STATUS    VOLUME             CAPACITY   ACCESSMODES   STORAGECLASS   AGE
homer-data-dashboard   Bound     gluster-volume-4   100Mi      RWX                          2s
homer-data-mysql       Bound     gluster-volume-3   300Mi      RWX                          2s
homer-data-semaphore   Bound     gluster-volume-5   100Mi      RWX                          2s
[centos@kube-master k8s]$ pwd
/home/centos/homer-docker/k8s
```

## And can you deploy?

Created services, created deployment... and...

looking freakin' close. We have the data bootstrapped and all pods actually run with a success (!?). But...

There's a few things that need another eye.

1. bootstrap pod is crash looping because it's a one-shot.
2. we might wanna try health / readiness checks.


