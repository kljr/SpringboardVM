#!/usr/bin/env bash

# Update Springboard site without touching springboard module, theme and library repos
# (except for sbsetup, which will get overwritten).

#Copies files *out of* a new springboard download and replaces them into an existing site.

echo "Type the relative path the drupal root of the site whose contrib modules you want to update, followed by [ENTER]:"
read path

echo "Type the Springboard-Build branch name that you want to replace contrib with, followed by [ENTER]:"
read branch

cd build
git checkout $branch
cd ../

# Check to see if the developer make file is available.
if [ -f build/springboard-developer.make ]; then
 drush make --no-gitinfofile build/springboard-developer.make tmp_contrib;
else
 # Use the standard make file.
 drush make --no-gitinfofile build/springboard-mtsb.make tmp_contrib;
fi;

rm -r $path/sites/all/modules/contrib
cp -R tmp_contrib/sites/all/modules/contrib $path/sites/all/modules/contrib
rm -r tmp_contrib/sites/all/libraries/springboard_advocacy
rm -r tmp_contrib/sites/all/libraries/springboard_composer

for FILE in tmp_contrib/sites/all/libraries/*; do
    if [[ -d $FILE ]]; then
      rm -r $path/sites/all/libraries/$(echo $FILE| cut -d'/' -f 5)
    fi;
done

\cp -R tmp_contrib/sites/all/libraries $path/sites/all/
rm -r tmp_contrib/sites

for FILE in tmp_contrib/*; do
    if [[ ! -d $FILE ]]; then
      rm -r $path/${FILE:12}
    fi;
done

\cp -R tmp_contrib/* $path

rm -r tmp_contrib