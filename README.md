# Kubernetes Setup Using Ansible

## Why Use Ansible?

Ansible is an infrastructure automation engine that automates software configuration management. It is agentless and
allows us to use SSH keys for connecting to remote machines. Ansible playbooks are written in yaml and offer inventory
management in simple text files.

## Prerequisites

1. Ansible should be installed in your machine. Refer to
   the [Ansible installation guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
   for platform specific installation.

2. SSH-Based login should be config between control-node and managed-node. Refer
   to [How To Configure SSH Key-Based Authentication on a Linux Server](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server)

### Hardware Prerequisites

#### Harbor

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU      | 2 CPU   | 4 CPU       |
| Mem      | 4 GB    | 8 GB        |
| Disk     | 40 GB   | 160 GB      |

#### Jenkins

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| Mem      | 256 MB  | 4 GB        |
| Disk     | 1 GB    | 50 GB       |

#### Gitlab

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU      | 4 CPU   | 8 CPU       |
| Mem      | 4 GB    | 8 GB        |
| Disk     | 2.5 GB  |             |

#### Kubernetes

```text
2 GB or more of RAM per machine
2 CPUs or more per machine
```

### OS Prerequisites

Ubuntu Server 22.04.2 LTS

## Feature List

- [x] Support container runtime:
    - [x] Docker
    - [x] Containerd
- [x] Kubernetes addons:
    - [x] Helm
    - [x] Metrics Server
    - [x] Nginx Ingress Controller
    - [x] Kubernetes Dashboard
    - [x] Cert Manager
- [x] Support container network:
    - [x] Calico
- [x] Support network file system:
    - [x] Linux NFS
- [x] CICD:
    - [x] Harbor
    - [x] Jenkins
    - [x] GitLab
- [x] Data center:
    - [x] Grafana UI
    - [x] InfluxDB
    - [x] Minio
    - [x] Elasticsearch
    - [x] Redis master replicas

## Usage

### Install Ansible

```shell
sudo sh install.sh
```

### Setup Platform (single mode)

```shell
# ---------------------------------------------------------------------------
# check ansible hosts can communication with each other 
ansible -i single-hosts.inventory all -m ping
# ---------------------------------------------------------------------------
# install kubernetes environment
ansible-playbook -i single-hosts.inventory ../playbook/setup-kubernetes.yml
# remove kubernetes master node taint
sudo kubectl taint nodes $(sudo kubectl get nodes --selector=node-role.kubernetes.io/master -o jsonpath='{.items[].metadata.name}') node-role.kubernetes.io/master:NoSchedule-
# install cicd environment
ansible-playbook -i single-hosts.inventory ../playbook/setup-cicd.yml
```

### Reset Platform (single mode)

```shell
# ---------------------------------------------------------------------------
# check ansible hosts can communication with each other 
ansible -i single-hosts.inventory all -m ping
# ---------------------------------------------------------------------------
# reset cicd environment
ansible-playbook -i single-hosts.inventory ../playbook/reset-cicd.yml
# reset kubernetes environment
ansible-playbook -i single-hosts.inventory ../playbook/reset-kubernetes.yml
```

### Setup Platform (cluster mode)

```shell
# ---------------------------------------------------------------------------
# check ansible hosts can communication with each other 
ansible -i multiple-hosts.inventory all -m ping
# ---------------------------------------------------------------------------
# install cicd environment
ansible-playbook -i multiple-hosts.inventory ../playbook/setup-cicd.yml
# install kubernetes environment
ansible-playbook -i multiple-hosts.inventory ../playbook/setup-kubernetes.yml
```

### Reset Platform (cluster mode)

```shell
# ---------------------------------------------------------------------------
# check ansible hosts can communication with each other 
ansible -i multiple-hosts.inventory all -m ping
# ---------------------------------------------------------------------------
# reset kubernetes environment
ansible-playbook -i multiple-hosts.inventory ../playbook/reset-kubernetes.yml
# reset cicd environment
ansible-playbook -i multiple-hosts.inventory ../playbook/reset-cicd.yml
```

## FAQ

### How to access kubernetes dashboard

```shell
sudo kubectl -n kube-system get secret $(sudo kubectl -n kube-system get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
```

### Access jenkins

```shell
cat /var/lib/jenkins/secrets/initialAdminPassword
admin/password
```

### Access gitlab

By default, a Linux package installation automatically generates a password for the initial administrator user account (
root) and stores it to /etc/gitlab/initial_root_password for at least 24 hours. For security reasons, after 24 hours,
this file is automatically removed by the first gitlab-ctl reconfigure.

```shell
cat /etc/gitlab/initial_root_password
```

### Ingress hostname

| Service name         | hostname                         |
|----------------------|----------------------------------|
| Kubernetes dashboard | dashboard.kubernetes.cluster.com |
| Minio                | minio.kubernetes.cluster.com     |
| InfluxDB             | influxdb.kubernetes.cluster.com  |
| Grafana              | grafana.kubernetes.cluster.com   |