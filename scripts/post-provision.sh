#!/usr/bin/env bash

PROJECT_ROOT=/var/www/springboard

cd ${PROJECT_ROOT}/sites/7.x-4.x
set -x
# Set Drupal variable to above directory 'encrypt_secure_key_path'
drush vset encrypt_secure_key_path ${PROJECT_ROOT}/sites/7.x-4.x/sites/default/files/
