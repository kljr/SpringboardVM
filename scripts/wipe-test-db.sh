#!/usr/bin/env bash
SBVM_ROOT=/var/www/springboard/sites
script_dir="$(dirname "$0")"
source "$script_dir/parse-yaml.sh"
cd $script_dir
export PATH=$PWD:$PATH
cd ../

MAIN_CONFIG_FILE=config/config.yml
eval $(parse_yaml ${MAIN_CONFIG_FILE})
echo "Type the springboard root directory of the site who's db you wish to replace [ENTER]:"
read dir
sa=@${springboard_vm_drush_alias_uniqifier}${dir}
drush  $sa sql-drop -y
gunzip < sites/${dir}/.circleci/springboard.sql.gz | drush $sa sql-cli
drush $sa updb -y
drush $sa vset encrypt_secure_key_path ${SBVM_ROOT}/${dir}/web/sites/default/files/
drush $sa cc all

