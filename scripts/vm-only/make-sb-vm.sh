#!/usr/bin/env bash

source "/vagrant/scripts/parse-yaml.sh"

# Build a default springboard site and a site
# for each vhost defined in local.config.yml.
MAIN_CONFIG_FILE=/vagrant/config/config.yml
eval $(parse_yaml ${MAIN_CONFIG_FILE})
#( set -o posix ; set ) | more

# First site built on composer install/update.
if [ ! -d /vagrant/sites/${drupal_core_dir} ]; then
   # Check to see if the developer make file is available.
#   if [ -f /vagrant/build/springboard-developer.make ]; then
#     drush make --no-gitinfofile build/springboard-developer.make /vagrant/sites/${drupal_core_dir};
#   else
#     # If no developer make, use the standard make file.
#     drush make --no-gitinfofile --working-copy build/springboard-mtsb.make /vagrant/sites/${drupal_core_dir};
#   fi;

     drush make --no-gitinfofile --working-copy /vagrant/build/springboard-mtsb.make /vagrant/sites/${drupal_core_dir};
    # add springboard to drupal core's .gitignore.
  if [ -d /vagrant/sites/${drupal_core_dir} ]; then
    cd /vagrant/sites/${drupal_core_dir};
    echo /vagrant/sites/all >> .gitignore; echo profiles/sbsetup >> .gitignore;
    cd ../../
    else
      echo "The drupal directory doesn't exist. Drush make must have failed."
  fi;
fi;

if [ ! -d /vagrant/sites/${drupal_testing_dir} ]; then
   # Check to see if the developer make file is available.
#   if [ -f build/springboard-developer.make ]; then
#     drush make --no-gitinfofile /vagrant/build/springboard-developer.make /vagrant/sites/${drupal_testing_dir};
#   else
#     # If no developer make, use the standard make file.
#     drush make --no-gitinfofile --working-copy /vagrant/build/springboard-mtsb.make /vagrant/sites/${drupal_testing_dir};
#   fi;
   drush make --no-gitinfofile --working-copy /vagrant/build/springboard-mtsb.make /vagrant/sites/${drupal_testing_dir};

  if [ -d /vagrant/sites/${drupal_testing_dir} ]; then
    cd /vagrant/sites/${drupal_testing_dir};
    echo /vagrant/sites/all >> .gitignore; echo profiles/sbsetup >> .gitignore;
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
    for vhost in ${!apache_vhosts__documentroot*}
    do
        # Get the docroot directory name.
        directory=${!vhost}
        directory=${directory/__/\/}
        if [ ! -d /vagrant/sites/$directory ]; then
            echo "Type the branch name that you want to check out into the directory $directory, followed by [ENTER]:"
            read branch
            cd /vagrant/build
            git checkout $branch
            cd ../
            # Check to see if the developer make file is available.
#            if [ -f build/springboard-developer.make ]; then
#                drush make --no-gitinfofile build/springboard-developer.make /vagrant/sites/$directory;
#            else
#                # Use the standard make file.
#                drush make --no-gitinfofile --working-copy build/springboard-mtsb.make /vagrant/sites/$directory;
#            fi;
            drush make --no-gitinfofile --working-copy build/springboard-mtsb.make /vagrant/sites/$directory;

            if [ -d /vagrant/sites/$directory} ]; then
              cd /vagrant/sites/$directory;
              echo /vagrant/sites/all >> .gitignore; echo profiles/sbsetup >> .gitignore;
              cd ../../
              # Create a sustainer.key file in /vagrant/sites/default/files
              mkdir -p /vagrant/sites/$directory/sites/default/files
              if [ ! -e /vagrant/sites/$directory/sites/default/files/sustainer.key ]; then
                echo $directory > /vagrant/sites/$directory/sites/default/files/sustainer.key
              fi;
            fi;
        fi;

    done
fi