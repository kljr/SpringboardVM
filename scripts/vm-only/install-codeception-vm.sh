#!/usr/bin/env bash

# Add codeception config files
if [ -d /vagrant/acceptance-tests ] && [ ! -f /vagrant/acceptance-tests/codeception.yml ]; then
    \cp /vagrant/templates/codeception/codeception.yml /vagrant/acceptance-tests
    \cp /vagrant/templates/codeception/acceptance.suite.yml /vagrant/acceptance-tests/tests
fi;

if [ -d /vagrant/acceptance-tests ] && [ ! -d /vagrant/acceptance-tests/vendor ]; then
    cd /vagrant/acceptance-tests
    /usr/bin/composer about 2> /dev/null
    if [ $? -eq 0 ]; then
        /usr/bin/composer update
    else
         echo "Please run 'composer update' from the acceptance-tests directory too!"
    fi;
fi;
