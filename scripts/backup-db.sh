#!/usr/bin/env bash

# This can only be run by vagrant or from within the VM. Don't try this at home.
echo "Backing up db..."
   DATE=`date +%Y-%m-%d:%H:%M:%S`
   sudo mysqldump -u root -proot --all-databases > /vagrant/backups/dbs/alldb_$DATE.sql
echo "DB backup done."