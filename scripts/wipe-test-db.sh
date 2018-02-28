#!/usr/bin/env bash
drush @sb-sb_testing sql-drop -y
gunzip < sites/sb_testing/.circleci/springboard.sql.gz | drush @sb-sb_testing sql-cli
drush @sb-sb_testing updb -y
drush @sb-sb_testing dm-prep
