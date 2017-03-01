#!/usr/bin/env bash

# Deal with relative paths
script_dir="$(dirname "$0")"
cd $script_dir
export PATH=$PWD:$PATH
cd ../

echo "Type the docroot of the site you want to update, followed by [ENTER]:"
read docroot
path="sites/$docroot"

if [ ! -d $path ]; then
  echo "Can't find that directory."
  exit 0
fi

echo "Type the foldername in the artifacts directory whose files and database you want to load. [ENTER]:"
read artifact

if [ ! -d artifacts/sites/$artifact ]; then
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
    if [ ! -f artifacts/sites/$artifact/files.tar.gz ]; then
      echo "Can't find the files directory in that artifact."
      exit 0
    gunzip artifacts/sites/$artifact/files.tar.gz
    tar -xf artifacts/sites/$artifact/files.tar -C artifacts/sites/$artifact/

        if [ -d artifacts/sites/$artifact/files ]; then
            echo "untarring"
            if [ -d $path/sites/default/files ]; then
                echo "Delete $path/sites/default/files"
                select yn in "Yes" "No"; do
                    case $yn in
                        Yes ) echo "removing files"; sudo rm -r $path/sites/default/files; break;;
                        No ) FILES=false; break;;
                    esac
                done
            fi

            if [ -d $path/sites/default ]  && ${FILES} = true; then
                  echo "moving files"
                  sudo mv artifacts/sites/$artifact/files $path/sites/default
                  echo "files moved"
              else
                  echo "Can't find the file path"
            fi
        gzip artifacts/sites/$artifact/files.tar
        fi
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
    if [ ! -f artifacts/sites/$artifact/dump.sql.gz ]; then
      echo "Can't find the sql dump in that artifact."
      exit 0
    fi
    echo "loading db"
    gunzip artifacts/sites/$artifact/dump.sql.gz
    if [ -f artifacts/sites/$artifact/dump.sql ]; then
       drush @#$docroot sql-drop
       echo "Importing db"
       drush @#$docroot sql-cli < artifacts/sites/$artifact/dump.sql
       echo "DB finished"
       gzip artifacts/sites/$artifact/dump.sql
    fi
fi

