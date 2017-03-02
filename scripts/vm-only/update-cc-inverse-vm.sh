#!/usr/bin/env bash

# Update Springboard site without touching springboard module, theme and library repos
# (except for sbsetup, which will get overwritten).

#Copies files *out of* a new springboard download and replaces them into an existing site.

echo "Type the docroot folder name of the site you want to update, followed by [ENTER]:"
read docroot
docpath="/vagrant/sites/$docroot"

if [ ! -d $docpath ]; then
  echo "Can't find that directory."
  exit 0
fi

echo "Making backup, please wait..."
DATE=`date +%Y-%m-%d:%H:%M:%S`
cp -R $docpath /vagrant/backups/sites/${docroot}_$DATE

echo "Type the Springboard-Build branch name that you want to replace contrib with, followed by [ENTER]:"
read branch
echo "Building Springboard"

cd /vagrant/build
git checkout $branch
cd ../

# Check to see if the developer make file is available.
#if [ -f build/springboard-developer.make ]; then
# drush make --no-gitinfofile build/springboard-developer.make /vagrant/tmp_springboard;
#else
# # Use the standard make file.
# drush make --no-gitinfofile --working-copy build/springboard-mtsb.make /vagrant/tmp_springboard;
#fi;

drush make --no-gitinfofile --working-copy build/springboard-mtsb.make /vagrant/tmp_springboard;

echo "Updating Springboard $docpath"

rm -r /vagrant/tmp_springboard/sites/all/libraries/springboard_advocacy
rm -r /vagrant/tmp_springboard/sites/all/libraries/springboard_composer

for FILE in /vagrant/tmp_springboard/sites/all/modules/contrib/*; do
    if [[ -d $FILE ]]; then
      rm -r $docpath/sites/all/modules/contrib/$(echo $FILE| cut -d'/' -f 6)
    fi;
done

\cp -R /vagrant/tmp_springboard/sites/all/modules/contrib/* $docpath/sites/all/modules/contrib

for FILE in /vagrant/tmp_springboard/sites/all/libraries/*; do
    if [[ -d $FILE ]]; then
      rm -r $docpath/sites/all/libraries/$(echo $FILE| cut -d'/' -f 5)
    fi;
done

\cp -R /vagrant/tmp_springboard/sites/all/libraries $docpath/sites/all/
rm -r /vagrant/tmp_springboard/sites

#for FILE in /vagrant/tmp_springboard/*; do
#    if [[ ! -d $FILE ]]; then
#     echo $docpath/${FILE}
#
#      rm -r $docpath/${FILE:12}
#    fi;
#done

\cp -R /vagrant/tmp_springboard/* $docpath

rm -r /vagrant/tmp_springboard
echo "Done. If there are changes to the Springboard-owned themes, modules or libraries in the new version you just swapped out, you'll need to do a git checkout in each of their folders to get them."