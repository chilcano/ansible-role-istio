# Ansible Role: istio

An Ansible Role that deploys Istio (https://istio.io) in an OpenShift cluster running locally, generally created by using Minishift (https://www.openshift.org/minishift).
This Role performs the following tasks:

- Check if OpenShift is running locally.
- Downloads and installs the specified version or latest of Istio.
- Uses the latest `oc` binary from `~/.minishift/cache/oc/<VERSION>/<OS>/` and `istioctl` from downloaded Istio binary.

## Prerequisites

- Ansible 2.3+
- Prior to running the role, clear your terminal session of any DOCKER* environment variables.
- `sudo` access in your host is required for installing `istioctl` (optional).
- OpenShift running locally. See `https://galaxy.ansible.com/chilcano/minishift` to get OpenShift running in a VM.

## Observations

The Istio Ansible Role has been tested with:
- minishift v1.11.0+4459917
- kubernetes 3.7
- istio 0.2.7
- VirtualBox 5.1.30
- macOS High Sierra, version 10.13.2 (17C88)

## Default Role variables

The default variables are in `defaults/main.yml`.

## Example Playbook

See `sample-1-istio.yml` file for an example.

```
$ cat sample-1-istio.yml
```

```yaml
---
- name: Install Istio.
  hosts: Pisc0
  connection: local
  gather_facts: yes
  vars:
    vm: openshift0

  roles:
    - role: chilcano.istio
      istio:
        action_to_trigger: clean  # [ deploy | clean ]
        action:
          deploy:
            istioctl: true    # istioctl
            core: true        # core components
            addons: true      # prometheus, graphana, zipkin, servicegraph
            sample_apps: true # bookinfo
        minishift:
          profile: "{{ vm }}"
        openshift:
          project: istio-system    # default
          hostname: "{{ vm }}"
          admin_usr: "system:admin"
          admin_pwd: anypassword
          istio_usr: developer
          istio_pwd: anypassword
        repo:
          #release_tag_name: ""   # latest
          release_tag_name: "0.2.7"
          #release_tag_name: "0.2.6"
```

## Using the Ansible Role

Install the role:
```
$ sudo ansible-galaxy install chilcano.istio
```

Copy the playbook from your roles path to the current working directory:
```
$ cp ${ANSIBLE_ROLES_PATH}/chilcano.istio/sample-1-istio.yml .
```

Create an `inventory` file
```
$ echo $(hostname) > ./inventory
```

Run the playbook:
```
$ ansible-playbook -i inventory --ask-become-pass sample-1-istio.yml
```

When Playbook execution has been finished, check if all Pods, Services, etc. have been deployed and running.

```
$ eval $(minishift oc-env)

$ oc project bookinfo

$ oc status
In project bookinfo on server https://192.168.99.100:8443

svc/details - 172.30.229.55:9080
  pod/details-v1-1464079269-2g4zf runs istio/examples-bookinfo-details-v1:0.2.3, docker.io/istio/proxy_debug:0.2.7

svc/productpage - 172.30.99.163:9080
  pod/productpage-v1-3915871613-mc87n runs istio/examples-bookinfo-productpage-v1:0.2.3, docker.io/istio/proxy_debug:0.2.7

svc/ratings - 172.30.96.18:9080
  pod/ratings-v1-327106889-p8hz7 runs istio/examples-bookinfo-ratings-v1:0.2.3, docker.io/istio/proxy_debug:0.2.7

svc/reviews - 172.30.179.156:9080
  pod/reviews-v3-1994447391-r9mfn runs istio/examples-bookinfo-reviews-v3:0.2.3, docker.io/istio/proxy_debug:0.2.7
  pod/reviews-v1-3806695627-6swvd runs istio/examples-bookinfo-reviews-v1:0.2.3, docker.io/istio/proxy_debug:0.2.7
  pod/reviews-v2-3096629009-jq6tp runs istio/examples-bookinfo-reviews-v2:0.2.3, docker.io/istio/proxy_debug:0.2.7

View details with 'oc describe <resource>/<name>' or list everything with 'oc get all'.

$ oc get pods
NAME                              READY     STATUS            RESTARTS   AGE
details-v1-1464079269-n75st       0/2       PodInitializing   0          7m
productpage-v1-3915871613-hl68p   0/2       PodInitializing   0          7m
ratings-v1-327106889-4c6cs        0/2       PodInitializing   0          7m
reviews-v1-3806695627-44qkz       0/2       PodInitializing   0          7m
reviews-v2-3096629009-d7r76       0/2       PodInitializing   0          7m
reviews-v3-1994447391-dd7vs       0/2       PodInitializing   0          7m
```

Finally you will see Istio and BookInfo App running in your OpenShift Cluster. The `PodInitializing` means that BookInfo App is being initializing and it isn't ready to use.

* Exploring all Istio components (select `istio-system` namespace).

![Selecting istio-system namespace](https://github.com/chilcano/ansible-minishift-istio-security/blob/master/imgs/api-mesh-security-7-weave-scope-istio-system.png "Selecting istio-system namespace")

* Exploring BookInfo App deployed on OpenShift (select `bookinfo` namespace).

![Selecting bookinfo namespace](https://github.com/chilcano/ansible-minishift-istio-security/blob/master/imgs/api-mesh-security-8-weave-scope-bookinfo.png "Selecting bookinfo namespace")

* Exploring in depth the BookInfo App.

![Exploring in depth the API Mesh](https://github.com/chilcano/ansible-minishift-istio-security/blob/master/imgs/api-mesh-security-9-weave-scope-bookinfo-mesh.png "Exploring in depth the API Mesh")

* Using BookInfo Web App and making calls to BookInfo APIs.

![Using BookInfo App deployed on OpenShift](https://github.com/chilcano/ansible-minishift-istio-security/blob/master/imgs/api-mesh-security-3-istio-bookinfo-app.png "Using BookInfo App deployed on OpenShift")

* The Istio Addons: Tracing with Zipkin.

![Tracing with Zipkin](https://github.com/chilcano/ansible-minishift-istio-security/blob/master/imgs/api-mesh-security-4-istio-zipkin.png "Tracing with Zipkin")

* The Istio Addons: Exploring metrics with Grafana.

![Exploring metrics with Grafana](https://github.com/chilcano/ansible-minishift-istio-security/blob/master/imgs/api-mesh-security-5-istio-grafana.png "Exploring metrics with Grafana")

* The Istio Addons: Viewing the flows with ServiceGraph.

![Viewing the flows with ServiceGraph](https://github.com/chilcano/ansible-minishift-istio-security/blob/master/imgs/api-mesh-security-6-istio-servicegraph.png "Viewing the flows with ServiceGraph")


## License

MIT / BSD

## Author Information

This role was created in 2017 by [Roger Carhuatocto](https://www.linkedin.com/in/rcarhuatocto), author of [HolisticSecurity.io Blog](https://holisticsecurity.io).
