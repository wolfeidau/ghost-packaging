# Setup

To get started update the hosts file with your devices.

Then run:

```
ansible all -i hosts -a "apt-get -y install python-apt" -s
```

Then run:

```
ansible-playbook setup.yaml -i hosts
```