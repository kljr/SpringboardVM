#!/usr/bin/env bash

DR_NEW_VHOSTS=TRUE DRUPALVM_ANSIBLE_ARGS='--start-at-task=*DruVMoser baby*' ANSIBLE_ROLES_PATH=vendor/geerlingguy/drupal-vm/provisioning/roles vagrant provision
