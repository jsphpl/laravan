#!/bin/bash

echo "Installing vendor roles from Ansible Galaxy…"
ansible-galaxy install -r requirements.yml