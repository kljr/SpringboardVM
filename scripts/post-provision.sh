#!/usr/bin/env bash

# This can only be run from the VM.

DRUV_ROOT=/var/www/springboard/sites
source "/vagrant/scripts/parse-yaml.sh"

MAIN_CONFIG_FILE=/vagrant/config/config.yml
eval $(parse_yaml ${MAIN_CONFIG_FILE})
cd ${DRUV_ROOT}/${drupal_core_dir}
set -x

cd ${DRUV_ROOT}/${drupal_core_dir}
 if [ ! -f sites/default/settings.php ]; then
    /usr/local/bin/drush site-install sbsetup -y --site-name=${drupal_core_project_dir} --root=${DRUV_ROOT}/${drupal_core_dir} --account-name=admin  --account-pass=admin --db-url=mysql://root:root@localhost/${drupal_core_project_dir}
    /usr/local/bin/drush vset encrypt_secure_key_path ${DRUV_ROOT}/${drupal_core_dir}/sites/default/files/
fi;

cd ${DRUV_ROOT}/${drupal_testing_dir}
 if [ ! -f sites/default/settings.php ]; then
    /usr/local/bin/drush site-install sbsetup -y --site-name=${drupal_testing_project_dir} --root=${DRUV_ROOT}/${drupal_testing_dir}  --account-name=admin  --account-pass=admin --db-url=mysql://root:root@localhost/${drupal_testing_project_dir}
    /usr/local/bin/drush vset encrypt_secure_key_path ${DRUV_ROOT}/${drupal_testing_dir}/sites/default/files/
fi;

# Create a sustainer.key file in sites/default/files
if [ ! -f ${DRUV_ROOT}/${drupal_core_dir}/sites/default/files ]; then
    mkdir -p ${DRUV_ROOT}/${drupal_core_dir}/sites/default/files
    if [ ! -e ${DRUV_ROOT}/${drupal_core_dir}/sites/default/files/sustainer.key ]; then
      echo ${vagrant_hostname} > ${DRUV_ROOT}/${drupal_core_dir}/sites/default/files/sustainer.key
    fi
fi
if [ ! -f ${DRUV_ROOT}/${drupal_testing_dir}/sites/default/files ]; then
    mkdir -p ${DRUV_ROOT}/${drupal_testing_dir}/sites/default/files
    if [ ! -e ${DRUV_ROOT}/${drupal_testing_dir}/sites/default/files/sustainer.key ]; then
      echo ${drupal_testing_dir} > ${DRUV_ROOT}/${drupal_testing_dir}/sites/default/files/sustainer.key
    fi
fi


cd ${DRUV_ROOT}

LOCAL_CONFIG_FILE=/vagrant/config/local.config.yml
if [ -f ${LOCAL_CONFIG_FILE} ]; then
    # Parse the local config yml file into the global vars.
    eval $(parse_yaml ${LOCAL_CONFIG_FILE})
    #( set -o posix ; set ) | more
    for vhost in ${!apache_vhosts__projectroot*}
        do
            # Get the docroot directory name.
            directory=${!vhost}
            directory=${directory/__/\/}
            if [ ! -f ${DRUV_ROOT}/$directory/web/sites/default/settings.php ]; then
              #( set -o posix ; set ) | more
              cd ${DRUV_ROOT}/$directory
              /usr/local/bin/drush sql-create -y --root=${DRUV_ROOT}/$directory/web --db-su=root --db-su-pw=root --db-url="mysql://drupal_db_user:drupal_db_password@127.0.0.1/$directory"
              /usr/local/bin/drush site-install sbsetup -y --root=${DRUV_ROOT}/$directory/web --site-name=$directory --account-name=admin  --account-pass=admin --db-url="mysql://root:root@127.0.0.1/$directory"
              /usr/local/bin/drush vset encrypt_secure_key_path ${DRUV_ROOT}/$directory/web/sites/default/files/
            fi;

            if [ ! -f ${DRUV_ROOT}/$directory/web/sites/default/files ]; then
                mkdir -p ${DRUV_ROOT}/$directory/web/sites/default/files
            fi
            if [ ! -e ${DRUV_ROOT}/$directory/web/sites/default/files/sustainer.key ]; then
                echo ${directory} > ${DRUV_ROOT}/$directory/web/sites/default/files/sustainer.key
            fi
        done
fi;