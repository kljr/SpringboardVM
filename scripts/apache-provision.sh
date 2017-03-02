#!/usr/bin/env bash

#deprecated, use druv-provision.sh

DR_NEW_VHOSTS=TRUE DRUPALVM_ANSIBLE_ARGS='--start-at-task=*DruVMoser baby*' vagrant provision
