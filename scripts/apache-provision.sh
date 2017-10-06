#!/usr/bin/env bash

#deprecated, use sbvm-provision.sh

DR_NEW_VHOSTS=TRUE DRUPALVM_ANSIBLE_ARGS='--start-at-task=SpringboardVM' vagrant provision
