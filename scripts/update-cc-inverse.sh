#!/usr/bin/env bash

if [ $HOME != '/home/vagrant' ]; then
    vagrant ssh -c "/vagrant/scripts/vm-only/update-cc-inverse-vm.sh"
else
    /vagrant/scripts/vm-only/update-cc-inverse-vm.sh
fi
