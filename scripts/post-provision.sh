#!/usr/bin/env bash

PROJECT_ROOT=/var/www/springboard

cd ${PROJECT_ROOT}/web
set -x
# Set Drupal variable to above directory 'encrypt_secure_key_path'
drush vset encrypt_secure_key_path ${PROJECT_ROOT}/web/sites/default/files/
