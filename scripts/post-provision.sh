#!/usr/bin/env bash

PROJECT_ROOT=/var/www/springboard

cd ${PROJECT_ROOT}/sites/sb_default
set -x
# Set Drupal variable to above directory 'encrypt_secure_key_path'
drush vset encrypt_secure_key_path ${PROJECT_ROOT}/sites/sb_default/sites/default/files/

cd ${PROJECT_ROOT}
CONFIG_FILE=config/local.config.yml

function parse_yaml_for_vhosts {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
        if ($2 == "documentroot") {
             split($3, dirname, "/")
             vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
             printf("%s%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, "__"dirname[2], dirname[2]);
         }
      }
   }'
}

# Parse the local config yml file into the global vars.
eval $(parse_yaml_for_vhosts ${CONFIG_FILE})
#( set -o posix ; set ) | more
for vhost in ${!apache_vhosts__documentroot*}
    do
        # Get the docroot directory name.
        directory=${!vhost}
        directory=${directory/__/\/}
        if [ ! -f ${PROJECT_ROOT}/sites/$directory/sites/default/settings.php ]; then
          cd ${PROJECT_ROOT}/sites/$directory
          drush site-install sbsetup -y --site-name=$directory --account-name=admin  --account-pass=admin --db-url=mysql://root:root@localhost/$directory
          drush vset encrypt_secure_key_path ${PROJECT_ROOT}/sites/$directory/sites/default/files/
        fi;
    done
