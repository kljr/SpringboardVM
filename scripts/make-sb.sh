#!/usr/bin/env bash
export COMPOSER_PROCESS_TIMEOUT=600;
#touch /tmp/txt
#echo $( printenv ) > /tmp/txt

# Deal with relative paths
script_dir="$(dirname "$0")"
source "$script_dir/parse-yaml.sh"
cd $script_dir
export PATH=$PWD:$PATH
cd ../
# Build a default springboard site and a site
# for each vhost defined in local.config.yml.
MAIN_CONFIG_FILE=config/config.yml
eval $(parse_yaml ${MAIN_CONFIG_FILE})
#( set -o posix ; set ) | more
# First site built on composer install/update.
if [ ! -d sites ]; then
  mkdir sites
fi;
if [ ! -d sites/${drupal_core_project_dir} ]; then
  if [ -d vendor/jacksonriver/springboard-composer ]; then
    cp -R vendor/jacksonriver/springboard-composer sites/${drupal_core_project_dir}
    else
      cp -R springboard-composer sites/${drupal_core_project_dir}
  fi;
  if [ -d sites/${drupal_core_project_dir} ]; then
    cd sites/${drupal_core_project_dir};
    git checkout develop
    git pull
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
  if [ -d vendor/jacksonriver/springboard-composer ]; then
    cp -R vendor/jacksonriver/springboard-composer sites/${drupal_testing_project_dir}
    else
      cp -R springboard-composer sites/${drupal_testing_project_dir}
  fi;
  if [ -d sites/${drupal_testing_project_dir} ]; then
    cd sites/${drupal_testing_project_dir};
    git checkout develop
    git pull
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
        cd $script_dir
        cd ../
        if [ ! -d sites/$directory ]; then
            echo "Building new site into directory $directory"
            read -p "Repository name? (default: springboard-composer): " repo
            [ -z "${repo}" ] && repo='springboard-composer'
            if [ $repo = 'springboard-composer' ]; then
                if [ -d vendor/jacksonriver/springboard-composer ]; then
                    cp -R vendor/jacksonriver/springboard-composer sites/$directory
                else
                    cp -R springboard-composer sites/$directory
                fi;
            else
                git clone git@github.com:JacksonRiver/$repo.git sites/$directory
            fi;
            cd sites/$directory;
            read -p "Branch name? (default: develop): " branch
            [ -z "${branch}" ] && branch='develop'
            git pull
            git checkout $branch
            git pull
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
                            echo "Could not find composer"
                    fi;
                fi;
            fi;
            cd ../../
        fi;
    done
fi