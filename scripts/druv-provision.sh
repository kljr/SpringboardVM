#!/usr/bin/env bash

DR_NEW_VHOSTS=TRUE DRUPALVM_ANSIBLE_ARGS='--start-at-task=DruVMoser' vagrant provision