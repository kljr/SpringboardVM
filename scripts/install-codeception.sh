#!/usr/bin/env bash

# Add codeception config files
if [ -d sites/sb_testing ] && [ ! -f sites/sb_testing/tests/codeception.yml ]; then
    \cp templates/codeception/codeception.yml sites/sb_testing/tests
fi;
if [ -d sites/sb_testing ] && [ ! -f sites/sb_testing/tests/functional.suite.yml ]; then
    \cp templates/codeception/functional.suite.yml sites/sb_testing/tests
fi;
if [ -d sites/sb_testing ] && [ ! -f sites/sb_testing/tests/acceptance.suite.yml ]; then
    \cp templates/codeception/acceptance.suite.yml sites/sb_testing/tests
fi;
