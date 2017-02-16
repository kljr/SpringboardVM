#!/usr/bin/env bash

CONFIG_FILE=config/local.config.yml

function parse_yaml {
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
             dirname=substr($3,2)
             sub(/\//, "__", dirname)
             vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
             printf("%s%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, "__"dirname, dirname);
         }
      }
   }'
}


if [ ! -d sites/7.x-4.x ]; then drush make --no-gitinfofile build/springboard-developer.make sites/7.x-4.x; fi;
cd sites/7.x-4.x echo sites/all >> .gitignore; echo profiles/sbsetup >> .gitignore; cd ../../

eval $(parse_yaml ${CONFIG_FILE})

for vhost in ${!apache_vhosts__documentroot*}
do
    directory=${!vhost}
    directory=${directory/__/\/}
echo $vhost


    if [ ! -d $directory ]; then
       echo "Type the branch name that you want to check out into the directory $directory, followed by [ENTER]:"

       read branch
       cd build
       git checkout $branch
       cd ../

       #drush make --no-gitinfofile build/springboard-developer.make $directory;
    fi;

   # cd $directory; echo sites/all >> .gitignore; echo profiles/sbsetup >> .gitignore; cd ../../
   cd build
   git checkout 7.x-4.x
   cd ../
done



