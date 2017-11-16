#!/usr/bin/env bash

# Add codeception config files
if [ -d sites/sb_testing/tests ] && [ ! -f sites/sb_testing/tests/codeception.yml ]; then
    \cp templates/codeception/codeception.yml sites/sb_testing/tests
    \cp templates/codeception/acceptance.suite.yml sites/sb_testing/tests/tests
fi;

if [ -d sites/sb_testing/tests/ ] && [ ! -d sites/sb_testing/tests/vendor ]; then
    cd sites/sb_testing/tests/
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
                    /usr/local/bin/composer update
                else
                    echo "Please run 'composer update' from the sites/sb_testing/tests/ directory too!"
            fi;
       fi;
    fi;
    cd ../
fi;