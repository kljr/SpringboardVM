#!/usr/bin/env bash

echo "Type the docroot of the site you want to update, followed by [ENTER]:"
read docroot
docpath="/vagrant/sites/$docroot"

if [ ! -d $docpath ]; then
  echo "Can't find that directory."
  exit 0
fi

echo "Type the foldername in the artifacts directory whose files and database you want to load. [ENTER]:"
read artifact

if [ ! -d /vagrant/artifacts/sites/$artifact ]; then
  echo "Can't find the artifacts directory."
  exit 0
fi

echo "Do you wish to move artifact files"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) FILES=true; break;;
        No ) FILES=false; break;;
    esac
done


if [ ${FILES} = true ]; then
    if [ ! -f /vagrant/artifacts/sites/$artifact/files.tar.gz ]; then
      echo "Can't find the files archive in that artifact."
      exit 0
    fi
    gunzip /vagrant/artifacts/sites/$artifact/files.tar.gz
    mkdir /vagrant/artifacts/sites/$artifact/files
    tar -xf /vagrant/artifacts/sites/$artifact/files.tar -C /vagrant/artifacts/sites/$artifact/files

    if [ -d /vagrant/artifacts/sites/$artifact/files ] && [ "$(ls -A /vagrant/artifacts/sites/$artifact/files)" ]; then
        echo "untarring"
        if [ -d $docpath/sites/default/files ]; then
            echo "Delete $docpath/sites/default/files"
            select yn in "Yes" "No"; do
                case $yn in
                    Yes ) echo "removing files"; sudo rm -r $docpath/sites/default/files; break;;
                    No ) FILES=false; break;;
                esac
            done
        fi

        if [ -d $docpath/sites/default ]  && [ ${FILES} = true ]; then
              echo "moving files"
              sudo mv /vagrant/artifacts/sites/$artifact/files $docpath/sites/default
              echo "files moved"
        else
              rm -r /vagrant/artifacts/sites/$artifact/files; echo $PWD;
              echo "Can't find the file path, or you cancelled."
        fi
    gzip /vagrant/artifacts/sites/$artifact/files.tar
    else
        exit 0;
    fi
fi

echo "Do you wish to load the artifact db"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) DB=true; break;;
        No ) DB=false; break;;
    esac
done

if [ ${DB} = true ]; then
    if [ ! -f /vagrant/artifacts/sites/$artifact/dump.sql.gz ]; then
      echo "Can't find the sql dump in that artifact."
      exit 0
    fi
    echo "loading db"
    gunzip /vagrant/artifacts/sites/$artifact/dump.sql.gz
    if [ -f /vagrant/artifacts/sites/$artifact/dump.sql ]; then
       cd /vagrant/sites/$docroot
       drush sql-drop
       echo "Importing db"
       drush sql-cli < /vagrant/artifacts/sites/$artifact/dump.sql
       echo "DB finished"
       gzip /vagrant/artifacts/sites/$artifact/dump.sql
    fi
fi
