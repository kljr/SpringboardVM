#!/usr/bin/env bash
SBVM_ROOT=/var/www/springboard/sites
source "/vagrant/scripts/parse-yaml.sh"
MAIN_CONFIG_FILE=/vagrant/config/config.yml
eval $(parse_yaml ${MAIN_CONFIG_FILE})
echo "Enter the project root directory of the site whose db you wish to replace [ENTER]:"
read dir
sa=@${springboard_vm_drush_alias_uniqifier}${dir}
drush  $sa dm-wipe -y
drush $sa updb -y
drush $sa vset encrypt_secure_key_path ${SBVM_ROOT}/${dir}/web/sites/default/files/
drush $sa cc all

