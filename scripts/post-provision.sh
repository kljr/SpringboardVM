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
    /usr/local/bin/drush site-install minimal -y --site-name=${drupal_core_project_dir} --root=${SBVM_ROOT}/${drupal_core_dir} --account-name=admin  --account-pass=admin --db-url=mysql://root:root@localhost/${drupal_core_project_dir}
    drush @sb-${drupal_core_project_dir} sql-drop -y
    gunzip < ${SBVM_ROOT}/${drupal_core_project_dir}/.circleci/springboard.sql.gz | drush @sb-${drupal_core_project_dir} sql-cli
    /usr/local/bin/drush vset encrypt_secure_key_path ${SBVM_ROOT}/${drupal_core_dir}/sites/default/files/
fi;

cd ${SBVM_ROOT}/${drupal_testing_dir}
if [ ! -f sites/default/settings.php ]; then
    /usr/local/bin/drush site-install minimal -y --site-name=${drupal_testing_project_dir} --root=${SBVM_ROOT}/${drupal_testing_dir}  --account-name=admin  --account-pass=admin --db-url=mysql://root:root@localhost/${drupal_testing_project_dir}
     drush @sb-${drupal_testing_project_dir} sql-drop -y
     gunzip < ${SBVM_ROOT}/${drupal_testing_project_dir}/.circleci/springboard.sql.gz | drush @sb-${drupal_testing_project_dir} sql-cli
    /usr/local/bin/drush vset encrypt_secure_key_path ${SBVM_ROOT}/${drupal_testing_dir}/sites/default/files/
fi;

# Create a sustainer.key file in sites/default/files
if [ ! -f ${SBVM_ROOT}/${drupal_core_dir}/sites/default/files ]; then
    mkdir -p ${SBVM_ROOT}/${drupal_core_dir}/sites/default/files
fi
if [ ! -e ${SBVM_ROOT}/${drupal_core_dir}/sites/default/files/sustainer.key ]; then
  echo ${drupal_domain} > ${SBVM_ROOT}/${drupal_core_dir}/sites/default/files/sustainer.key
fi
if [ ! -f ${SBVM_ROOT}/${drupal_testing_dir}/sites/default/files ]; then
    mkdir -p ${SBVM_ROOT}/${drupal_testing_dir}/sites/default/files
fi
if [ ! -e ${SBVM_ROOT}/${drupal_testing_dir}/sites/default/files/sustainer.key ]; then
  echo 'sbvm-test.dev' > ${SBVM_ROOT}/${drupal_testing_dir}/sites/default/files/sustainer.key
fi

cd /var/www/springboard

if [ -d ${SBVM_ROOT}/${drupal_core_project_dir} ] && [ ! -f ${SBVM_ROOT}/${drupal_core_project_dir}/tests/codeception.yml ]; then
    \cp templates/codeception/codeception.yml ${SBVM_ROOT}/${drupal_core_project_dir}/tests
fi;
if [ -d ${SBVM_ROOT}/${drupal_core_project_dir} ] && [ ! -f ${SBVM_ROOT}/${drupal_core_project_dir}/tests/functional.suite.yml ]; then
    \cp templates/codeception/functional.suite.yml ${SBVM_ROOT}/${drupal_core_project_dir}/tests
fi;
if [ -d ${SBVM_ROOT}/${drupal_core_project_dir} ] && [ ! -f ${SBVM_ROOT}/${drupal_core_project_dir}/tests/acceptance.suite.yml ]; then
    \cp templates/codeception/acceptance.suite.yml ${SBVM_ROOT}/${drupal_testing_project_dir}/tests
fi;

if [ -d ${SBVM_ROOT}/${drupal_testing_project_dir} ] && [ ! -f ${SBVM_ROOT}/${drupal_testing_project_dir}/tests/codeception.yml ]; then
    \cp templates/codeception/codeception.yml ${SBVM_ROOT}/${drupal_testing_project_dir}/tests
fi;
if [ -d ${SBVM_ROOT}/${drupal_testing_project_dir} ] && [ ! -f ${SBVM_ROOT}/${drupal_testing_project_dir}/tests/functional.suite.yml ]; then
    \cp templates/codeception/functional.suite.yml ${SBVM_ROOT}/${drupal_testing_project_dir}/tests
fi;
if [ -d ${SBVM_ROOT}/${drupal_testing_project_dir} ] && [ ! -f ${SBVM_ROOT}/${drupal_testing_project_dir}/tests/acceptance.suite.yml ]; then
    \cp templates/codeception/acceptance.suite.yml ${SBVM_ROOT}/${drupal_testing_project_dir}/tests
fi;

cd ${SBVM_ROOT}

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
            if [ ! -f ${SBVM_ROOT}/$directory/web/sites/default/settings.php ]; then
          #    ( set -o posix ; set ) | more
              cd ${SBVM_ROOT}/$directory
              /usr/local/bin/drush sql-create -y --root=${SBVM_ROOT}/$directory/web --db-su=root --db-su-pw=root --db-url="mysql://drupal_db_user:drupal_db_password@127.0.0.1/$directory"
              /usr/local/bin/drush site-install minimal -y --root=${SBVM_ROOT}/$directory/web --site-name=$directory --account-name=admin  --account-pass=admin --db-url="mysql://root:root@127.0.0.1/$directory"
              drush @sb-$directory sql-drop -y
              gunzip < ${SBVM_ROOT}/$directory/.circleci/springboard.sql.gz | drush @sb-$directory sql-cli
              /usr/local/bin/drush vset encrypt_secure_key_path ${SBVM_ROOT}/$directory/web/sites/default/files/
            fi;

        done

    for servername in ${!apache_vhosts__*}
        do

            name=${!servername}
            directory=${servername}

            if [[ $directory = *"servername"* ]]; then
                name=${name/__/\/}
                directory=${directory/apache_vhosts__servername__/}

                if [ ! -f ${SBVM_ROOT}/$directory/web/sites/default/files ]; then
                    mkdir -p ${SBVM_ROOT}/$directory/web/sites/default/files
                fi
                if [ ! -e ${SBVM_ROOT}/$directory/web/sites/default/files/sustainer.key ]; then
                    echo ${name} > ${SBVM_ROOT}/$directory/web/sites/default/files/sustainer.key
                fi

                cd /var/www/springboard
                if [ -d ${SBVM_ROOT}/$directory ] && [ ! -f ${SBVM_ROOT}/$directory/tests/codeception.yml ]; then
                    \cp templates/codeception/codeception.yml ${SBVM_ROOT}/$directory/tests
                fi;
                if [ -d ${SBVM_ROOT}/$directory ] && [ ! -f ${SBVM_ROOT}/$directory/tests/functional.suite.yml ]; then
                    \cp templates/codeception/functional.suite.yml ${SBVM_ROOT}/$directory/tests
                    sed -i -e "s/sbvm-test\.dev/${name}/g" ${SBVM_ROOT}/$directory/tests/functional.suite.yml
                fi;
                if [ -d ${SBVM_ROOT}/$directory ] && [ ! -f ${SBVM_ROOT}/$directory/tests/acceptance.suite.yml ]; then
                    \cp templates/codeception/acceptance.suite.yml ${SBVM_ROOT}/$directory/tests
                fi;

            fi
        done


fi;