#!/usr/bin/env bash

# This can only be run from the VM.

SBVM_ROOT=/var/www/springboard/sites
source "/vagrant/scripts/parse-yaml.sh"

MAIN_CONFIG_FILE=/vagrant/config/config.yml
eval $(parse_yaml ${MAIN_CONFIG_FILE})
cd ${SBVM_ROOT}/${drupal_core_dir}
set -x

cd ${SBVM_ROOT}/${drupal_core_dir}
 if [ ! -f sites/default/settings.php ]; then
     chmod 775 web/sites/default
    /usr/local/bin/drush site-install sbsetup -y --site-name=${drupal_core_project_dir} --root=${SBVM_ROOT}/${drupal_core_dir} --account-name=admin  --account-pass=admin --db-url=mysql://root:root@localhost/${drupal_core_project_dir}
    /usr/local/bin/drush vset encrypt_secure_key_path ${SBVM_ROOT}/${drupal_core_dir}/sites/default/files/
fi;

cd ${SBVM_ROOT}/${drupal_testing_dir}
if [ ! -f sites/default/settings.php ]; then
    chmod 775 web/sites/default
    /usr/local/bin/drush site-install sbsetup -y --site-name=${drupal_testing_project_dir} --root=${SBVM_ROOT}/${drupal_testing_dir}  --account-name=admin  --account-pass=admin --db-url=mysql://root:root@localhost/${drupal_testing_project_dir}
    /usr/local/bin/drush vset encrypt_secure_key_path ${SBVM_ROOT}/${drupal_testing_dir}/sites/default/files/
    /usr/local/bin/drush sql-drop -y --db-url=mysql://root:root@localhost/${drupal_testing_project_dir}
    if [ ! -f ../.circleci/springboard.sql ]; then
      gunzip -c ../.circleci/springboard.sql.gz > ../.circleci/springboard.sql
    else
      rm ../.circleci/springboard.sql
      gunzip -c ../.circleci/springboard.sql.gz > ../.circleci/springboard.sql
    fi;

    /usr/local/bin/drush sql-query --file=../.circleci/springboard.sql --db-url=mysql://root:root@localhost/${drupal_testing_project_dir}
fi;

# Create a sustainer.key file in sites/default/files
if [ ! -f ${SBVM_ROOT}/${drupal_core_dir}/sites/default/files ]; then
    mkdir -p ${SBVM_ROOT}/${drupal_core_dir}/sites/default/files
    if [ ! -e ${SBVM_ROOT}/${drupal_core_dir}/sites/default/files/sustainer.key ]; then
      echo ${vagrant_hostname} > ${SBVM_ROOT}/${drupal_core_dir}/sites/default/files/sustainer.key
    fi
fi
if [ ! -f ${SBVM_ROOT}/${drupal_testing_dir}/sites/default/files ]; then
    mkdir -p ${SBVM_ROOT}/${drupal_testing_dir}/sites/default/files
fi

if [ ! -e ${SBVM_ROOT}/${drupal_testing_dir}/sites/default/files/sustainer.key ]; then
    echo sbvm-test.dev > ${SBVM_ROOT}/${drupal_testing_dir}/sites/default/files/sustainer.key
fi


cd ${SBVM_ROOT}

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
            if [ ! -f ${SBVM_ROOT}/$directory/web/sites/default/settings.php ]; then
              #( set -o posix ; set ) | more
              chmod 775 ${SBVM_ROOT}/$directory/web/sites/default/
              cd ${SBVM_ROOT}/$directory
              /usr/local/bin/drush sql-create -y --root=${SBVM_ROOT}/$directory/web --db-su=root --db-su-pw=root --db-url="mysql://drupal_db_user:drupal_db_password@127.0.0.1/$directory"
              /usr/local/bin/drush site-install sbsetup -y --root=${SBVM_ROOT}/$directory/web --site-name=$directory --account-name=admin  --account-pass=admin --db-url="mysql://root:root@127.0.0.1/$directory"
              /usr/local/bin/drush vset encrypt_secure_key_path ${SBVM_ROOT}/$directory/web/sites/default/files/
            fi;

            if [ ! -f ${SBVM_ROOT}/$directory/web/sites/default/files ]; then
                mkdir -p ${SBVM_ROOT}/$directory/web/sites/default/files
            fi
            key=apache_vhosts__${directory}_sustainer_key
            if [ ! -e ${SBVM_ROOT}/$directory/web/sites/default/files/sustainer.key ]; then
                echo ${key} > ${SBVM_ROOT}/$directory/web/sites/default/files/sustainer.key
             else
                rm ${SBVM_ROOT}/$directory/web/sites/default/files/sustainer.key
                echo ${!key} > ${SBVM_ROOT}/$directory/web/sites/default/files/sustainer.key
            fi
        done


fi;