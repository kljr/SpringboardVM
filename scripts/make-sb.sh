#!/usr/bin/env bash

yaml_dir="$(dirname "$0")"
source "$yaml_dir/parse-yaml.sh"

# Build a default springboard site and a site
# for each vhost defined in local.config.yml.
MAIN_CONFIG_FILE=config/config.yml
eval $(parse_yaml ${MAIN_CONFIG_FILE})
#( set -o posix ; set ) | more

# First site built on composer install/update.
if [ ! -d sites/${drupal_core_dir} ]; then
   # Check to see if the developer make file is available.
   if [ -f build/springboard-developer.make ]; then
     drush make --no-gitinfofile build/springboard-developer.make sites/${drupal_core_dir};
   else
     # If no developer make, use the standard make file.
     drush make --no-gitinfofile --working-copy build/springboard-mtsb.make sites/${drupal_core_dir};
   fi;
    # add springboard to drupal core's .gitignore.
    cd sites/${drupal_core_dir};
    echo sites/all >> .gitignore; echo profiles/sbsetup >> .gitignore;
    cd ../../
fi;

if [ ! -d sites/${drupal_testing_dir} ]; then
   # Check to see if the developer make file is available.
   if [ -f build/springboard-developer.make ]; then
     drush make --no-gitinfofile build/springboard-developer.make sites/${drupal_testing_dir};
   else
     # If no developer make, use the standard make file.
     drush make --no-gitinfofile --working-copy build/springboard-mtsb.make sites/${drupal_testing_dir};
   fi;
    cd sites/${drupal_testing_dir};
    echo sites/all >> .gitignore; echo profiles/sbsetup >> .gitignore;
    cd ../../
fi;



LOCAL_CONFIG_FILE=config/local.config.yml

if [ -f ${LOCAL_CONFIG_FILE} ]; then
    # Parse the local config yml file into the global vars.
    eval $(parse_yaml ${LOCAL_CONFIG_FILE})
    #( set -o posix ; set ) | more
    for vhost in ${!apache_vhosts__documentroot*}
    do
        # Get the docroot directory name.
        directory=${!vhost}
        directory=${directory/__/\/}
        if [ ! -d sites/$directory ]; then
            echo "Type the branch name that you want to check out into the directory $directory, followed by [ENTER]:"
            read branch
            cd build
            git checkout $branch
            cd ../
            # Check to see if the developer make file is available.
            if [ -f build/springboard-developer.make ]; then
                drush make --no-gitinfofile build/springboard-developer.make sites/$directory;
            else
                # Use the standard make file.
                drush make --no-gitinfofile --working-copy build/springboard-mtsb.make sites/$directory;
            fi;
            cd sites/$directory;
            echo sites/all >> .gitignore; echo profiles/sbsetup >> .gitignore;
            cd ../../
            # Create a sustainer.key file in sites/default/files
            mkdir -p sites/$directory/sites/default/files
            if [ ! -e sites/$directory/sites/default/files/sustainer.key ]; then
              echo $directory > sites/$directory/sites/default/files/sustainer.key
            fi;
        fi;

    done
fi