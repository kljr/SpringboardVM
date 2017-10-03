#!/usr/bin/env bash

source "/vagrant/scripts/parse-yaml.sh"

# Build a default springboard site and a site
# for each vhost defined in local.config.yml.
MAIN_CONFIG_FILE=/vagrant/config/config.yml
eval $(parse_yaml ${MAIN_CONFIG_FILE})
#( set -o posix ; set ) | more

if [ ! -d /vagrant/sites ]; then
  mkdir sites
fi;

# First site built on composer install/update.
if [ ! -d /vagrant/sites/${drupal_core_dir} ]; then

    cd springboard-composer
    git checkout develop
    git pull
    cd ../
    cp -R springboard-composer sites/${drupal_core_project_dir}

    # add springboard to drupal core's .gitignore.
  if [ -d /vagrant/sites/${drupal_core_dir} ]; then
    cd /vagrant/sites/${drupal_core_dir}
    /usr/bin/composer run-script dev-install
    cd ../../
    else
      echo "The drupal directory doesn't exist. Drush make must have failed."
  fi;
fi;

if [ ! -d /vagrant/sites/${drupal_testing_dir} ]; then

     cd springboard-composer
     git checkout develop
     git pull
     cd ../
     cp -R springboard-composer sites/${drupal_core_project_dir}

    # add springboard to drupal core's .gitignore.
  if [ -d /vagrant/sites/${drupal_core_dir} ]; then
    cd /vagrant/sites/${drupal_core_dir}
    /usr/bin/composer run-script dev-install
    cd ../../
    else
      echo "The drupal directory doesn't exist. Drush make must have failed."
  fi;
fi;

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
        if [ ! -d /vagrant/sites/$directory/web ]; then
            echo "Type the branch name that you want to check out into the directory $directory, followed by [ENTER]:"
            read branch
            cp -R springboard-composer /vagrant/sites/$directory
            cd sites/$directory;
            /usr/bin/composer run-script dev-install
            if [ ! -e sites/$directory/web/sites/default/files/sustainer.key ]; then
              echo $directory > sites/$directory/sites/default/files/sustainer.key
            fi;
            cd ../../
        fi;
    done
fi