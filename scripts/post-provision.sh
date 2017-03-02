#!/usr/bin/env bash

# This can only be run from the VM.

PROJECT_ROOT=/var/www/springboard/sites
source "/vagrant/scripts/parse-yaml.sh"

MAIN_CONFIG_FILE=/vagrant/config/config.yml
eval $(parse_yaml ${MAIN_CONFIG_FILE})
cd ${PROJECT_ROOT}/${drupal_core_dir}
set -x

cd ${PROJECT_ROOT}/${drupal_core_dir}
 if [ ! -f sites/default/settings.php ]; then
    /usr/local/bin/drush site-install sbsetup -y --site-name=${drupal_core_dir} --account-name=admin  --account-pass=admin --db-url=mysql://root:root@localhost/${drupal_core_dir}
    /usr/local/bin/drush vset encrypt_secure_key_path ${PROJECT_ROOT}/${drupal_core_dir}/sites/default/files/
fi;

cd ${PROJECT_ROOT}/${drupal_testing_dir}
 if [ ! -f sites/default/settings.php ]; then
    /usr/local/bin/drush site-install sbsetup -y --site-name=${drupal_testing_dir} --account-name=admin  --account-pass=admin --db-url=mysql://root:root@localhost/${drupal_testing_dir}
    /usr/local/bin/drush vset encrypt_secure_key_path ${PROJECT_ROOT}/${drupal_testing_dir}/sites/default/files/
fi;

cd ${PROJECT_ROOT}

LOCAL_CONFIG_FILE=/vagrant/config/local.config.yml
if [ -f ${LOCAL_CONFIG_FILE} ]; then
    # Parse the local config yml file into the global vars.
    eval $(parse_yaml ${LOCAL_CONFIG_FILE})
    #( set -o posix ; set ) | more
    for vhost in ${!apache_vhosts__documentroot*}
        do
            # Get the docroot directory name.
            directory=${!vhost}
            directory=${directory/__/\/}
            if [ ! -f ${PROJECT_ROOT}/$directory/sites/default/settings.php ]; then
              cd ${PROJECT_ROOT}/$directory
              /usr/local/bin/drush site-install sbsetup -y --site-name=$directory --account-name=admin  --account-pass=admin --db-url=mysql://root:root@localhost/$directory
              /usr/local/bin/drush vset encrypt_secure_key_path ${PROJECT_ROOT}/$directory/sites/default/files/
            fi;
            if [ ! -f ${PROJECT_ROOT}/$directory/sites/default/files ]; then
                mkdir -p ${PROJECT_ROOT}/$directory/sites/default/files
            fi
            if [ ! -e ${PROJECT_ROOT}/$directory/sites/default/files/sustainer.key ]; then
                echo ${directory} > ${PROJECT_ROOT}/$directory/sites/default/files/sustainer.key
            fi
        done
fi;

cp /vagrant/templates/drushrc.php /home/vagrant/.drush/drushrc.php
chown vagrant:vagrant /home/vagrant/.drush/drushrc.php

if [ ! -f /home/vagrant/.bashrc_druv ]; then
  cat /vagrant/templates/bashrc_guest_include >> /home/vagrant/.bashrc
fi

cp /vagrant/templates/bashrc_guest /home/vagrant/.bashrc_druv
chown vagrant:vagrant /home/vagrant/.bashrc_druv