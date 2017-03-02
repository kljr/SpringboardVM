#!/usr/bin/env bash


if [ $HOME == '/home/vagrant' ] || ( [ $PWD == '/home/vagrant' ] &&  [ $HOME == '/root' ] ); then
    /vagrant/scripts/vm-only/install-codeception-vm.sh
else
    vagrant ssh -c "/vagrant/scripts/vm-only/install-codeception-vm.sh"
fi
