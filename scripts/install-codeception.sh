#!/usr/bin/env bash

# Add codeception config files
if [ -d acceptance-tests ] && [ ! -f acceptance-tests/codeception.yml ]; then
    \cp templates/codeception/codeception.yml acceptance-tests
    \cp templates/codeception/acceptance.suite.yml acceptance-tests/tests
fi;

if [ -d acceptance-tests ] && [ ! -d acceptance-tests/vendor ]; then
    cd acceptance-tests
    $HOME/composer.phar about 2> /dev/null
    if [ $? -eq 0 ]; then
        $HOME/composer.phar update
        else
            $HOME/composer about 2> /dev/null
            if [ $? -eq 0 ]; then
                $HOME/composer update
            else
                /usr/local/bin/composer about 2> /dev/null
                if [ $? -eq 0 ]; then
                /usr/local/bin/composer/composer update
                else
                    echo "Please run composer update from the acceptance-tests directory too!"
            fi;
       fi;
    fi;
    cd ../
fi;
