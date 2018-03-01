#!/usr/bin/env bash

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
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            if ($2 == "projectroot") {
                split($3, dirname, "/")
                if (dirname[2] != "") {
                    printf("%s%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, "__"dirname[2], dirname[2]);
                }
            }
            else if ($2 == "servername") {
                printf("%s%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, "__"dirname[2], $3);
            }
            else {
               printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);            }
        }
   }'
}