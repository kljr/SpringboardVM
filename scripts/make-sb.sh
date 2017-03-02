#!/usr/bin/env bash

#touch /tmp/txt
#echo $( printenv ) > /tmp/txt

if [ $HOME == '/home/vagrant' ] || ( [ $PWD == '/home/vagrant' ] &&  [ $HOME == '/root' ] ); then
    /vagrant/scripts/vm-only/make-sb-vm.sh
else
    vagrant ssh -c "/vagrant/scripts/vm-only/make-sb-vm.sh"
fi
