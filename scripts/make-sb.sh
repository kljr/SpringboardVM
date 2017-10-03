#!/usr/bin/env bash

#touch /tmp/txt
#echo $( printenv ) > /tmp/txt

# Deal with relative paths
script_dir="$(dirname "$0")"
source "$script_dir/parse-yaml.sh"
cd $script_dir
export PATH=$PWD:$PATH
cd ../


if ! command -v drush >/dev/null 2>&1; then
  echo "You need drush to run this script. Please install drush globally."
  exit 0;
fi


# Build a default springboard site and a site
# for each vhost defined in local.config.yml.
MAIN_CONFIG_FILE=config/config.yml
eval $(parse_yaml ${MAIN_CONFIG_FILE})
#( set -o posix ; set ) | more
# First site built on composer install/update.
if [ ! -d sites/${drupal_core_project_dir} ]; then
     cd springboard-composer
     git checkout develop
     git pull
     cd ../
     cp -R springboard-composer sites/${drupal_core_project_dir}
  if [ -d sites/${drupal_core_project_dir} ]; then
    cd sites/${drupal_core_project_dir};
    $HOME/composer.phar about 2> /dev/null
    if [ $? -eq 0 ]; then
        $HOME/composer.phar run-script dev-install
        else
            $HOME/composer about 2> /dev/null
            if [ $? -eq 0 ]; then
                $HOME/composer run-script dev-install
            else
                /usr/local/bin/composer about 2> /dev/null
                if [ $? -eq 0 ]; then
                    /usr/local/bin/composer run-script dev-install
                else
                    echo "COuld not find composer"
            fi;
       fi;
    fi;

    cd ../../
    else
      echo "The drupal directory doesn't exist. Drush make must have failed."
  fi;
fi;

if [ ! -d sites/${drupal_testing_project_dir} ]; then

     cd springboard-composer
     git checkout develop
     git pull
     cd ../
     cp -R springboard-composer sites/${drupal_testing_project_dir}

  if [ -d sites/${drupal_testing_project_dir} ]; then
    cd sites/${drupal_testing_project_dir};
    $HOME/composer.phar about 2> /dev/null
    if [ $? -eq 0 ]; then
        $HOME/composer.phar run-script dev-install
        else
            $HOME/composer about 2> /dev/null
            if [ $? -eq 0 ]; then
                $HOME/composer run-script dev-install
            else
                /usr/local/bin/composer about 2> /dev/null
                if [ $? -eq 0 ]; then
                    /usr/local/bin/composer run-script dev-install
                else
                    echo "COuld not find composer"
            fi;
       fi;
    fi;
    cd ../../
    else
      echo "The drupal directory doesn't exist. Drush make must have failed."
  fi;
fi;

LOCAL_CONFIG_FILE=config/local.config.yml

if [ -f ${LOCAL_CONFIG_FILE} ]; then
    # Parse the local config yml file into the global vars.
    eval $(parse_yaml ${LOCAL_CONFIG_FILE})
    #( set -o posix ; set ) | more
    for vhost in ${!apache_vhosts__projectroot*}
    do
        # Get the docroot directory name.
        directory=${!vhost}
        directory=${directory/__/\/}
        if [ ! -d sites/$directory ]; then
            echo "Type the branch name that you want to check out into the directory $directory, followed by [ENTER]:"
            read branch
            cd springboard-composer
            git pull
            git checkout $branch
            git pull
            cd ../
       fi;

       if [ ! -d sites/$directory/web} ]; then
            echo"sdfsdfs"
            cp -R springboard-composer sites/$directory
            cd sites/$directory;
            $HOME/composer.phar about 2> /dev/null
            if [ $? -eq 0 ]; then
                $HOME/composer.phar run-script dev-install
                else
                    $HOME/composer about 2> /dev/null
                    if [ $? -eq 0 ]; then
                        $HOME/composer run-script dev-install
                    else
                        /usr/local/bin/composer about 2> /dev/null
                        if [ $? -eq 0 ]; then
                            /usr/local/bin/composer run-script dev-install
                        else
                            echo "COuld not find composer"
                    fi;
                fi;
                 if [ ! -e sites/$directory/web/sites/default/files/sustainer.key ]; then
                echo $directory > sites/$directory/sites/default/files/sustainer.key
              fi;
              cd ../../
            fi;
        fi;

    done
fi