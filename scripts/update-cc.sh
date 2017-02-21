#!/usr/bin/env bash

# Update Springboard site without touching springboard module, theme and library repos
# (except for sbsetup, which will get overwritten).

# Copies existing site's repos *into* a new springboard download and
# renames the new springboard directory to the old springboard directory.

# Deal with relative paths
script_dir="$(dirname "$0")"
source "$script_dir/parse-yaml.sh"
cd $script_dir
export PATH=$PWD:$PATH
cd ../


echo "Type the relative path the drupal root of the site whose contrib modules you want to update, followed by [ENTER]:"
read path

echo "Type the Springboard-Build branch name that you want to replace contrib with, followed by [ENTER]:"
read branch

cd build
git checkout $branch
cd ../

# Check to see if the developer make file is available.
if [ -f build/springboard-developer.make ]; then
 drush make --no-gitinfofile build/springboard-developer.make tmp_springboard;
else
 # Use the standard make file.
 drush make --no-gitinfofile build/springboard-mtsb.make tmp_springboard;
fi;

rm -r tmp_springboard/sites/all/modules/springboard
rm -r tmp_springboard/sites/all/themes
rm -r tmp_springboard/sites/all/libraries/springboard_advocacy
rm -r tmp_springboard/sites/all/libraries/springboard_composer
rm -r tmp_springboard/sites/default

cp -R $path/sites/all/modules/springboard tmp_springboard/sites/all/modules
cp -R $path/sites/all/themes tmp_springboard/sites/all
cp -R $path/sites/all/libraries/springboard_advocacy tmp_springboard/sites/all/libraries
cp -R $path/sites/all/libraries/springboard_composer tmp_springboard/sites/all/libraries
cp -R $path/sites/default tmp_springboard/sites

echo "Making backup of $path"
mv $path backups/sites/${path:5}_$(date +%s)
mv tmp_springboard $path
echo "Done"