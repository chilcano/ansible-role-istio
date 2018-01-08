# Ansible Role: istio

An Ansible Role that deploy Istio (https://istio.io) in an OpenShift cluster running locally, generally created by using Minishift (https://www.openshift.org/minishift).
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
    istio_ms_hostname_and_profile: openshift0

  roles:
    #- role: ansible-role-istio
    - role: chilcano.istio
      istio:
        action_to_trigger: clean  # [ deploy | clean ]
        action:
          deploy:
            istioctl: true    # istioctl
            core: true        # core components
            addons: true      # prometheus, graphana, zipkin, servicegraph
            sample_apps: true # bookinfo
          clean: true
        minishift:
          profile: "{{ istio_ms_hostname_and_profile }}"
        openshift:
          project: istio-system    # default
          hostname: "{{ istio_ms_hostname_and_profile }}"
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

## License

MIT / BSD

## Author Information

This role was created in 2017 by [Roger Carhuatocto](https://www.linkedin.com/in/rcarhuatocto), author of [HolisticSecurity.io Blog](https://holisticsecurity.io).
