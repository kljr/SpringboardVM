#!/usr/bin/env bash

# This can only be run by vagrant or from within the VM. Don't try this at home.

USER="root"
PASSWORD="root"
DEST="/vagrant/backups/dbs"
DATE=`date +%Y-%m-%d:%H:%M:%S`

databases=`mysql -u $USER -p$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db"
        mysqldump -u $USER -p$PASSWORD --databases $db > $DEST/"$db"_$DATE.sql
        gzip $DEST/"$db"_$DATE.sql
    fi
done