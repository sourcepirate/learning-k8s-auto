## K8s Setup

The repo contains the code necessary to set up kubernetes cluster
via ansible and terraform

## Prerequisits

* terraform
* ansible
* an aws account

## Provisioning compute resources.

```
cd terraform/
terraform apply

```

## Ouputing all resource ips.

```
terraform output
```

## Running the playbook.

Update `ansible/hosts` file with proper ips from the above setup.
Also change the following files

* `ansible/master/defaults/main.yml`
* `ansible/worker/defaults/main.ym`

```
export ANSIBLE_HOST_KEY_CHECKING=False
cd ansible/
ansible-playbook main.yml -i hosts
```