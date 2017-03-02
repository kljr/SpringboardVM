#!/usr/bin/env bash

cp /vagrant/templates/drushrc.php /home/vagrant/.drush/drushrc.php
chown vagrant:vagrant /home/vagrant/.drush/drushrc.php

if [ ! -f /home/vagrant/.bashrc_druv ]; then
  cat /vagrant/templates/bashrc_guest_include >> /home/vagrant/.bashrc
fi

cp /vagrant/templates/bashrc_guest /home/vagrant/.bashrc_druv
chown vagrant:vagrant /home/vagrant/.bashrc_druv