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

function hhh() {
 FILES=true
}

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
    fi
    #tar -zxvf files.tar.gz
    echo "untarring"
    if [ -d $path/default/files ]; then
      echo "remoinv"
      #sudo rm -r $path/default/files
    fi

    if [ -d $path/default ]; then
      #mv files $path/default
      echo "moving files"
      else
      echo "Can't find the file path"
    fi
    #rm -r files
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
#    cd artifacts/sites/$artifact
#    gunzip dump.sql.gz
#    rm dump.sql
fi

