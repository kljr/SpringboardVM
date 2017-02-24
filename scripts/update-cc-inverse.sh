#!/usr/bin/env bash

# Update Springboard site without touching springboard module, theme and library repos
# (except for sbsetup, which will get overwritten).

#Copies files *out of* a new springboard download and replaces them into an existing site.

# Deal with relative paths
script_dir="$(dirname "$0")"
source "$script_dir/parse-yaml.sh"
cd $script_dir
export PATH=$PWD:$PATH
cd ../

echo "Type the relative path the drupal root of the site whose contrib modules you want to update, followed by [ENTER]:"
read path

echo "Making backup, please wait..."
DATE=`date +%Y-%m-%d:%H:%M:%S`
cp -R $path backups/sites/${path:5}_$DATE

echo "Type the Springboard-Build branch name that you want to replace contrib with, followed by [ENTER]:"
read branch
echo "Building Springboard"

cd build
git checkout $branch
cd ../

# Check to see if the developer make file is available.
#if [ -f build/springboard-developer.make ]; then
# vendor/bin/drush make --no-gitinfofile build/springboard-developer.make tmp_springboard;
#else
# # Use the standard make file.
# vendor/bin/drush make --no-gitinfofile --working-copy build/springboard-mtsb.make tmp_springboard;
#fi;

vendor/bin/drush make --no-gitinfofile --working-copy build/springboard-mtsb.make tmp_springboard;

echo "Updating Springboard $path"

rm -r tmp_springboard/sites/all/libraries/springboard_advocacy
rm -r tmp_springboard/sites/all/libraries/springboard_composer

for FILE in tmp_springboard/sites/all/modules/contrib/*; do
    if [[ -d $FILE ]]; then
      rm -r $path/sites/all/modules/contrib/$(echo $FILE| cut -d'/' -f 6)
    fi;
done

\cp -R tmp_springboard/sites/all/modules/contrib/* $path/sites/all/modules/contrib

for FILE in tmp_springboard/sites/all/libraries/*; do
    if [[ -d $FILE ]]; then
      rm -r $path/sites/all/libraries/$(echo $FILE| cut -d'/' -f 5)
    fi;
done

\cp -R tmp_springboard/sites/all/libraries $path/sites/all/
rm -r tmp_springboard/sites

#for FILE in tmp_springboard/*; do
#    if [[ ! -d $FILE ]]; then
#     echo $path/${FILE}
#
#      rm -r $path/${FILE:12}
#    fi;
#done

\cp -R tmp_springboard/* $path

rm -r tmp_springboard
echo "Done. If there are changes to the Springboard-owned themes, modules or libraries in the new version you just swapped out, you'll need to do a git checkout in each of their folders to get them."