#!/usr/bin/env bash

# This can only be run from the VM.

SBVM_ROOT=/var/www/springboard/
SBVM_SITES=/var/www/springboard/sites
source "/vagrant/scripts/parse-yaml.sh"

MAIN_CONFIG_FILE=/vagrant/config/config.yml
eval $(parse_yaml ${MAIN_CONFIG_FILE})
set -x

####
#### Set up the default site #####
####
cd ${SBVM_SITES}/${drupal_core_dir}
if [ ! -f sites/default/settings.php ]; then
    cp ${SBVM_ROOT}/templates/settings.php sites/default/settings.php
fi;
default_db_populated=$(mysql -uroot -proot sb_default -e 'show tables;' | grep system);
if [ ! $default_db_populated ]; then
    /usr/local/bin/drush sql-create -y
    gunzip < ${SBVM_SITES}/${drupal_core_project_dir}/.circleci/database.initdb.d/springboard.sql.gz | /usr/local/bin/drush sql-cli
    /usr/local/bin/drush vset encrypt_secure_key_path ${SBVM_SITES}/${drupal_core_dir}/sites/default/files/
    /usr/local/bin/drush upwd admin --password=admin -y
fi;
# Create a sustainer.key file in sites/default/files
if [ ! -f ${SBVM_SITES}/${drupal_core_dir}/sites/default/files ]; then
    mkdir -p ${SBVM_SITES}/${drupal_core_dir}/sites/default/files
fi
echo "23fe4ba7660eba65c8634fd41e18f2300eb2a1bcbbc6e81f1bde82448016890" > ${SBVM_SITES}/${drupal_core_dir}/sites/default/files/encrypt_key.key
if [ ! -e ${SBVM_SITES}/${drupal_core_dir}/sites/default/files/sustainer.key ]; then
  echo ${drupal_domain} > ${SBVM_SITES}/${drupal_core_dir}/sites/default/files/sustainer.key
fi
chmod 775 ${SBVM_SITES}/${drupal_core_dir}/sites/default
if [ -f  ${SBVM_ROOT}/${drupal_core_dir}/.circleci/drush-scripts/fix-encrypt-paths.php ]; then
  drush $sa scr ${SBVM_ROOT}/${drupal_core_dir}/.circleci/drush-scripts/fix-encrypt-paths.php '../.circleci/private-files/openssl'
fi;

####
#### Set up the testing site #####
####
cd ${SBVM_SITES}/${drupal_testing_dir}
if [ ! -f sites/default/settings.php ]; then
    cp ${SBVM_ROOT}/templates/settings.php sites/default/settings.php
    sed -i -e "s/sb_default/sb_testing/g" sites/default/settings.php
    sed -i -e "s/'.sbvm.local'/'.sbvm-test.local'/g" sites/default/settings.php
fi;
testing_db_populated=$(mysql -uroot -proot sb_testing -e 'show tables;' | grep system);
if [ ! $testing_db_populated ]; then
    /usr/local/bin/drush sql-create -y
    gunzip < ${SBVM_SITES}/${drupal_testing_project_dir}/.circleci/database.initdb.d/springboard.sql.gz | drush sql-cli
    /usr/local/bin/drush vset encrypt_secure_key_path ${SBVM_SITES}/${drupal_testing_dir}/sites/default/files/
    /usr/local/bin/drush upwd admin --password=admin -y
fi;
if [ ! -f ${SBVM_SITES}/${drupal_testing_dir}/sites/default/files ]; then
    mkdir -p ${SBVM_SITES}/${drupal_testing_dir}/sites/default/files
fi
echo "23fe4ba7660eba65c8634fd41e18f2300eb2a1bcbbc6e81f1bde82448016890" > ${SBVM_SITES}/${drupal_testing_dir}/sites/default/files/encrypt_key.key

if [ ! -e ${SBVM_SITES}/${drupal_testing_dir}/sites/default/files/sustainer.key ]; then
  echo 'sbvm-test.local' > ${SBVM_SITES}/${drupal_testing_dir}/sites/default/files/sustainer.key
fi
chmod 775 ${SBVM_SITES}/${drupal_testing_dir}/sites/default
if [ -f  ${SBVM_ROOT}/${drupal_testing_dir}/.circleci/drush-scripts/fix-encrypt-paths.php ]; then
  drush $sa scr ${SBVM_ROOT}/${drupal_testing_dir}/.circleci/drush-scripts/fix-encrypt-paths.php '../.circleci/private-files/openssl'
fi;

### set up the test config###
cd /var/www/springboard

if [ -d ${SBVM_SITES}/${drupal_core_project_dir} ] && [ ! -f ${SBVM_SITES}/${drupal_core_project_dir}/tests/codeception.yml ]; then
    \cp templates/codeception/codeception.yml ${SBVM_SITES}/${drupal_core_project_dir}/tests
    sed -i -e "s/sb_testing/${drupal_core_project_dir}/g" ${SBVM_SITES}/${drupal_core_project_dir}/tests/codeception.yml
fi;
if [ -d ${SBVM_SITES}/${drupal_core_project_dir} ] && [ ! -f ${SBVM_SITES}/${drupal_core_project_dir}/tests/functional.suite.yml ]; then
    \cp templates/codeception/functional.suite.yml ${SBVM_SITES}/${drupal_core_project_dir}/tests
    sed -i -e "s/sbvm-test\.local/${vagrant_machine_name}.local/g" ${SBVM_SITES}/${drupal_core_project_dir}/tests/functional.suite.yml
    sed -i -e "s/sb_testing/${drupal_core_project_dir}/g" ${SBVM_SITES}/${drupal_core_project_dir}/tests/functional.suite.yml
fi;
if [ -d ${SBVM_SITES}/${drupal_core_project_dir} ] && [ ! -f ${SBVM_SITES}/${drupal_core_project_dir}/tests/acceptance.suite.yml ]; then
    \cp templates/codeception/acceptance.suite.yml ${SBVM_SITES}/${drupal_testing_project_dir}/tests
fi;
if [ -d ${SBVM_SITES}/${drupal_testing_project_dir} ] && [ ! -f ${SBVM_SITES}/${drupal_testing_project_dir}/tests/codeception.yml ]; then
    \cp templates/codeception/codeception.yml ${SBVM_SITES}/${drupal_testing_project_dir}/tests
fi;
if [ -d ${SBVM_SITES}/${drupal_testing_project_dir} ] && [ ! -f ${SBVM_SITES}/${drupal_testing_project_dir}/tests/functional.suite.yml ]; then
    \cp templates/codeception/functional.suite.yml ${SBVM_SITES}/${drupal_testing_project_dir}/tests
fi;
if [ -d ${SBVM_SITES}/${drupal_testing_project_dir} ] && [ ! -f ${SBVM_SITES}/${drupal_testing_project_dir}/tests/acceptance.suite.yml ]; then
    \cp templates/codeception/acceptance.suite.yml ${SBVM_SITES}/${drupal_testing_project_dir}/tests
fi;

###
### Set up any other sites defined in local config
###
cd ${SBVM_SITES}
LOCAL_CONFIG_FILE=/vagrant/config/local.config.yml
if [ -f ${LOCAL_CONFIG_FILE} ]; then
    # Parse the local config yml file into the global vars.
    eval $(parse_yaml ${LOCAL_CONFIG_FILE})
    for vhost in ${!apache_vhosts__projectroot*}
        do
            # Get the docroot directory name.
            directory=${!vhost}
            directory=${directory/__/\/}
             #( set -o posix ; set ) | more
            cd ${SBVM_SITES}/$directory/web
            if [ ! -f ${SBVM_SITES}/$directory/web/sites/default/settings.php ]; then
                cp ${SBVM_ROOT}/templates/settings.php sites/default/settings.php
                sed -i -e "s/sb_default/${directory}/g" sites/default/settings.php
            fi;
            db_populated_directory=$(mysql -uroot -proot ${directory} -e 'show tables;' | grep system);
            if [ ! $db_populated_directory ]; then
                /usr/local/bin/drush sql-create -y
                gunzip < ${SBVM_SITES}/$directory/.circleci/database.initdb.d/springboard.sql.gz | /usr/local/bin/drush sql-cli
                /usr/local/bin/drush vset encrypt_secure_key_path ${SBVM_SITES}/$directory/web/sites/default/files/
                /usr/local/bin/drush upwd admin --password=admin -y
            fi;
            chmod 775 ${SBVM_SITES}/$directory/web/sites/default
            if [ -f  ${SBVM_ROOT}/$directory/.circleci/drush-scripts/fix-encrypt-paths.php ]; then
                drush $sa scr ${SBVM_ROOT}/$directory/.circleci/drush-scripts/fix-encrypt-paths.php '../.circleci/private-files/openssl'
            fi;
        done

    for servername in ${!apache_vhosts__*}
        do

            name=${!servername}
            directory=${servername}

            if [[ $directory = *"servername"* ]]; then
                name=${name/__/\/}
                directory=${directory/apache_vhosts__servername__/}
                sed -i -e "s/'.sbvm.local'/'.${name}'/g" ${SBVM_SITES}/$directory/web/sites/default/settings.php

                if [ ! -f ${SBVM_SITES}/$directory/web/sites/default/files ]; then
                    mkdir -p ${SBVM_SITES}/$directory/web/sites/default/files
                    chmod 775 ${SBVM_SITES}/$directory/web/sites/default/files
                fi
                if [ ! -e ${SBVM_SITES}/$directory/web/sites/default/files/sustainer.key ]; then
                    echo ${name} > ${SBVM_SITES}/$directory/web/sites/default/files/sustainer.key
                fi
                echo "23fe4ba7660eba65c8634fd41e18f2300eb2a1bcbbc6e81f1bde82448016890" > ${SBVM_SITES}/$directory/web/sites/default/files/encrypt_key.key


                cd /var/www/springboard
                if [ -d ${SBVM_SITES}/$directory ] && [ ! -f ${SBVM_SITES}/$directory/tests/codeception.yml ]; then
                    \cp templates/codeception/codeception.yml ${SBVM_SITES}/$directory/tests
                    sed -i -e "s/sb_testing/${directory}/g" ${SBVM_SITES}/$directory/tests/codeception.yml
                fi;
                if [ -d ${SBVM_SITES}/$directory ] && [ ! -f ${SBVM_SITES}/$directory/tests/functional.suite.yml ]; then
                    \cp templates/codeception/functional.suite.yml ${SBVM_SITES}/$directory/tests
                    sed -i -e "s/sbvm-test\.local/${name}/g" ${SBVM_SITES}/$directory/tests/functional.suite.yml
                    sed -i -e "s/sb_testing/${directory}/g" ${SBVM_SITES}/$directory/tests/functional.suite.yml
                fi;
                if [ -d ${SBVM_SITES}/$directory ] && [ ! -f ${SBVM_SITES}/$directory/tests/acceptance.suite.yml ]; then
                    \cp templates/codeception/acceptance.suite.yml ${SBVM_SITES}/$directory/tests
                fi;

            fi
        done

fi;