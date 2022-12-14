# Kubernetes Setup Using Ansible

## Why Use Ansible?

Ansible is an infrastructure automation engine that automates software configuration management. It is agentless and
allows us to use SSH keys for connecting to remote machines. Ansible playbooks are written in yaml and offer inventory
management in simple text files.

## Prerequisites

Ansible should be installed in your machine. Refer to
the [Ansible installation guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) for
platform specific installation.

Refer
to [How To Configure SSH Key-Based Authentication on a Linux Server](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server)

## Version Information

```text
OS: Ubuntu 18.04.6 LTS (bionic) 64-bit
Ansible: 2.9
Docker: 19.03.15
Docker Compose: 1.29.2
Kubernetes: 1.22.2
Metrics Server: 0.6.1
NFS Subdirectory External Provisioner: v4.0.2

Harbor: v1.9.4
Jenkins: 2.332.3
```

## Feature List

- [x] Kubernetes addons:
    - [x] Helm.
    - [x] Metrics Server.
    - [x] Kubernetes Dashboard.
    - [ ] Istio.
    - [ ] Weave Scope.
    - [ ] NGINX Ingress Controller.
    - [ ] Promethues Monitoring.
    - [ ] EFK Logging.
- [x] Support container network:
    - [x] Calico.
    - [ ] Flannel.
- [x] Support container runtime:
    - [x] Docker.
    - [ ] Containerd.
    - [ ] CRI-O.
- [x] Support network file system:
    - [x] Linux NFS.
- [ ] Highly available Kubernetes cluster.
- [ ] Full of the binaries installation.
- [x] CICD:
    - [x] Harbor.
    - [x] Jenkins.
    - [x] GitLab.   

## TODO List

- [ ] docker daemon.json should use to_nice_json format
- [ ] log files should save in unified folder

## Usage

```shell
# ---------------------------------------------------------------------------
# check ansible hosts can communication with each other 
ansible -i hosts.inventory all -m ping
# ---------------------------------------------------------------------------
# install cicd environment
ansible-playbook -i hosts.inventory ./playbook/setup-cicd.yml
# install kubernetes environment
ansible-playbook -i hosts.inventory ./playbook/setup-kubernetes.yml
# ---------------------------------------------------------------------------
# reset kubernetes environment
ansible-playbook -i hosts.inventory ./playbook/reset-kubernetes.yml
# reset cicd environment
ansible-playbook -i hosts.inventory ./playbook/reset-cicd.yml
```

## FAQ

### How to access kubernetes dashboard

```shell
kubectl -n kube-system get secret $(kubectl -n kube-system get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
```

### Access jenkins

```shell
cat /var/lib/jenkins/secrets/initialAdminPassword
admin/password
```

### Access gitlab

```shell
cat /etc/gitlab/initial_root_password
```
