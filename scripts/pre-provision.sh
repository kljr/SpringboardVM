#!/usr/bin/env bash

# This can only be run from the VM.

PROJECT_ROOT=/var/www/springboard/sites
CONFIG_FILE=/vagrant/config/config.yml

source "/vagrant/scripts/parse-yaml.sh"

eval $(parse_yaml ${CONFIG_FILE})

# Create a sustainer.key file in sites/default/files
if [ ! -f ${PROJECT_ROOT}/${drupal_core_dir}/sites/default/files ]; then
    mkdir -p ${PROJECT_ROOT}/${drupal_core_dir}/sites/default/files
    if [ ! -e ${PROJECT_ROOT}/${drupal_core_dir}/sites/default/files/sustainer.key ]; then
      echo ${vagrant_hostname} > ${PROJECT_ROOT}/${drupal_core_dir}/sites/default/files/sustainer.key
    fi
fi
if [ ! -f ${PROJECT_ROOT}/${drupal_testing_dir}/sites/default/files ]; then
    mkdir -p ${PROJECT_ROOT}/${drupal_testing_dir}/sites/default/files
    if [ ! -e ${PROJECT_ROOT}/${drupal_testing_dir}/sites/default/files/sustainer.key ]; then
      echo ${drupal_testing_dir} > ${PROJECT_ROOT}/${drupal_testing_dir}/sites/default/files/sustainer.key
    fi
fi