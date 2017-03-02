#!/usr/bin/env bash

# Update Springboard site without touching springboard module, theme and library repos
# (except for sbsetup, which will get overwritten).

# Copies existing site's repos *into* a new springboard download and
# renames the new springboard directory to the old springboard directory.

echo "Type the docroot folder name of the site whose repos you want to replace with symlinks [ENTER]:"
read docroot
docpath="/vagrant/sites/$docroot"

if [ ! -d $docpath ]; then
  echo "Can't find that directory."
  exit 0
fi


echo "This will remove the springboard repositories in $docpath. You will lose all git history, unpushed branches and stashes. Are you sure you want to do this?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) REPLACE=true; break;;
        No ) REPLACE=false; break;;
    esac
done

#echo "Making backup of $docpath"
#DATE=`date +%Y-%m-%d:%H:%M:%S`
#\cp -R $docpath /vagrant/backups/sites/${docroot}_$DATE

if [ ${REPLACE} = true ]; then
    rm -r $docpath/sites/all/modules/springboard
    rm -r $docpath/sites/all/themes/springboard_themes
    rm -r $docpath/sites/all/libraries/springboard_advocacy
    rm -r $docpath/profiles/sbsetup

    ln -s ../../../../../linked/springboard_modules $docpath/sites/all/modules/springboard
    ln -s ../../../../../linked/springboard_themes $docpath/sites/all/themes/springboard_themes
    ln -s ../../../../../linked/springboard_advocacy $docpath/sites/all/libraries/springboard_advocacy
    ln -s ../../../../../linked/sbsetup $docpath/profiles/sbsetup

    echo "links created"
fi;