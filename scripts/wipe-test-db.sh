if [ $HOME != '/home/vagrant' ]; then
    vagrant ssh -c "/vagrant/scripts/vm-only/wipe-test-db.sh"
else
    /vagrant/scripts/vm-only/wipe-test-db.sh
fi