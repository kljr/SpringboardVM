#!/usr/bin/env bash

# Build a default springboard site and a site
# for each vhost defined in local.config.yml.

# First site built on composer install/update.
if [ ! -d sites/first ]; then
   # Check to see if the developer make file is available.
   if [ -f build/springboard-developer.make ]; then
     drush make --no-gitinfofile build/springboard-developer.make sites/first;
     # add springboard to drupal core's .gitignore.
     cd sites/first echo sites/all >> .gitignore; echo profiles/sbsetup >> .gitignore;
     cd ../../
   else
     # If no developer make, use the standard make file.
     drush make --no-gitinfofile --working-copy build/springboard-mtsb.make sites/first;
   fi;
fi;

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
             printf("%s%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, "__"dirname[3], dirname[3]);
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
        if [ ! -d $directory ]; then

           echo "Type the branch name that you want to check out into the directory $directory, followed by [ENTER]:"
           read branch
           cd build
           git checkout $branch
           cd ../

           # Check to see if the developer make file is available.
           if [ -f build/springboard-developer.make ]; then
             drush make --no-gitinfofile build/springboard-developer.make sites/$directory;
             # add springboard to drupal core's .gitignore.
             cd sites/$directory echo sites/all >> .gitignore; echo profiles/sbsetup >> .gitignore;
             cd ../../
           else
             # Use the standard make file.
             drush make --no-gitinfofile --working-copy build/springboard-mtsb.make sites/$directory;
           fi;
           # Create a sustainer.key file in sites/default/files
           mkdir -p sites/$directory/sites/default/files
           if [ ! -e sites/$directory/sites/default/files/sustainer.key ]; then
              echo $directory > sites/$directory/sites/default/files/sustainer.key
           fi;
        fi;

    done