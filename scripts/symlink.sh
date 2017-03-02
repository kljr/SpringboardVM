#!/usr/bin/env bash

if [ $HOME != '/home/vagrant' ]; then
    vagrant ssh -c "/vagrant/scripts/vm-only/symlink-vm.sh"
else
    /vagrant/scripts/vm-only/symlink-vm.sh
fi