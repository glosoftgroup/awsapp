#!/usr/bin/env bash
#
# Set up Ansible on a Vagrant Ubuntu Precise box, then run the
# development playbook.

echo "provisioning...."

# ansible 2.0 seems to break some of the playbooks...needs further investigation
# for now use pip and pin ansible to 1.9.4
if [[ ! $(ansible --version 2> /dev/null) =~ 1\.6 ]]; then
    sudo apt-get update && \
    sudo apt-get -y install python-software-properties && \
    sudo apt-get -y install software-properties-common && \
    sudo apt-get -y install gcc build-essential libssl-dev libffi-dev python-dev && \
    sudo apt-get -y install python-pip && \
    sudo pip install -U pip && \
    sudo pip install ansible==2.1.1.0 && \
	sudo pip install virtualenv
fi

PYTHONUNBUFFERED=1 ansible-playbook /vagrant/devops/ansible_devops/installation.yml \
    --inventory-file=/vagrant/devops/ansible_devops/inventory/development \
    --connection=local --limit=app_servers
