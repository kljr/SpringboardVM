#!/usr/bin/env bash



# Update Springboard site without touching springboard module, theme and library repos
# (except for sbsetup, which will get overwritten).

# Copies existing site's repos *into* a new springboard download and
# renames the new springboard directory to the old springboard directory.

echo "Type the docroot folder name of the site you want to update, followed by [ENTER]:"
read docroot
docpath="/vagrant/sites/$docroot"

if [ ! -d $docpath ]; then
  echo "Can't find that directory."
  exit 0
fi

echo "Type the Springboard-Build branch name that you want to replace contrib with, followed by [ENTER]:"
read branch

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

tmp_dir="/vagrant/tmp_springboard"

if [ ! -d $tmp_dir ]; then
  echo "It appears that drush make failed"
  exit 0
fi

rm -r /vagrant/tmp_springboard/sites/all/modules/springboard
rm -r /vagrant/tmp_springboard/sites/all/themes
rm -r /vagrant/tmp_springboard/sites/all/libraries/springboard_advocacy
rm -r /vagrant/tmp_springboard/sites/all/libraries/springboard_composer
rm -r /vagrant/tmp_springboard/sites/default

cp -R $docpath/sites/all/modules/springboard /vagrant/tmp_springboard/sites/all/modules
cp -R $docpath/sites/all/themes /vagrant/tmp_springboard/sites/all
cp -R $docpath/sites/all/libraries/springboard_advocacy /vagrant/tmp_springboard/sites/all/libraries
cp -R $docpath/sites/all/libraries/springboard_composer /vagrant/tmp_springboard/sites/all/libraries
cp -R $docpath/sites/default /vagrant/tmp_springboard/sites

echo "Making backup of $docpath"
DATE=`date +%Y-%m-%d:%H:%M:%S`
mv $docpath /vagrant/backups/sites/${docroot}_$DATE
mv /vagrant/tmp_springboard $docpath
echo "Done. If there are changes to the Springboard-owned themes, modules or libraries in the new version you just swapped out, you'll need to do a git checkout in each of their folders to get them."