#!/usr/bin/env bash

PROJECT_ROOT=/var/www/springboard
CONFIG_FILE=${PROJECT_ROOT}/config/config.yml

source "${PROJECT_ROOT}/scripts/parse-yaml.sh"

eval $(parse_yaml ${CONFIG_FILE})

# Create a sustainer.key file in sites/default/files
if [ ! -f ${PROJECT_ROOT}/sites/${drupal_core_dir}/sites/default/files ]; then
    mkdir -p ${PROJECT_ROOT}/sites/${drupal_core_dir}/sites/default/files
    if [ ! -e ${PROJECT_ROOT}/sites/${drupal_core_dir}/sites/default/files/sustainer.key ]; then
      echo ${vagrant_hostname} > ${PROJECT_ROOT}/sites/${drupal_core_dir}/sites/default/files/sustainer.key
    fi
fi
if [ ! -f ${PROJECT_ROOT}/sites/${drupal_testing_dir}/sites/default/files ]; then
    mkdir -p ${PROJECT_ROOT}/sites/${drupal_testing_dir}/sites/default/files
    if [ ! -e ${PROJECT_ROOT}/sites/${drupal_testing_dir}/sites/default/files/sustainer.key ]; then
      echo ${drupal_testing_dir} > ${PROJECT_ROOT}/sites/${drupal_testing_dir}/sites/default/files/sustainer.key
    fi
fi