#!/usr/bin/env bash
SBVM_ROOT=/var/www/springboard/sites
source "/vagrant/scripts/parse-yaml.sh"
MAIN_CONFIG_FILE=/vagrant/config/config.yml
eval $(parse_yaml ${MAIN_CONFIG_FILE})
echo "Enter the project root directory of the site whose db you wish to replace [ENTER]:"
read dir
sa=@${springboard_vm_drush_alias_uniqifier}${dir}
drush  $sa sql-drop -y
 if [ -f ${SBVM_ROOT}/${dir}/.circleci/database.initdb.d/springboard.sql.gz ]; then
  gunzip < ${SBVM_ROOT}/${dir}/.circleci/database.initdb.d/springboard.sql.gz | drush $sa sql-cli
   else
   gunzip < ${SBVM_ROOT}/${dir}/.circleci/database.initdb.d/springboard.sql.gz | drush $sa sql-cli
 fi;drush $sa updb -y

drush $sa upwd admin --password=admin -y
drush $sa vset encrypt_secure_key_path ${SBVM_ROOT}/${dir}/web/sites/default/files/
drush $sa cc all
chmod 775 ${SBVM_ROOT}/${dir}/web/sites/default
if [ -f  ${SBVM_ROOT}/${dir}/.circleci/drush-scripts/fix-encrypt-paths.php ]; then
  drush $sa scr ${SBVM_ROOT}/${dir}/.circleci/drush-scripts/fix-encrypt-paths.php '../.circleci/private-files/openssl'
fi;