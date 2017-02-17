# Composer/Drush/DrupalVM template for Springboard projects

Creates one or more fully configured Springboard sites, plus a virtual machine to run them in.

Also downloads the acceptance test repo.

By default, a single Springboard site will be installed, running the 7.x-4.x branch. Additional Springboard
installs and vhosts can be defined by following the example in `local.config.yml.example`. If you create additional
sites the install script will prompt you for the Springboard version, which can be a branch or tag in the Springboard-Build repo.

## Prerequisites

- Linux or Mac (with NFS)
- [Composer](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx).
- VirtualBox
- Vagrant

If you have all of the following vagrant plugins, no network/IP configuration is required:

- [vagrant-auto_network](https://github.com/oscar-stack/vagrant-auto_network)
- [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)
- [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest)

Otherwise you will need to edit vagrant_ip in config.yml, and update /etc/hosts to
point springboardvm.dev at the IP you choose.

#Usage

Clone this repository.

Run `composer update`

If you defined any additional springboard installs on local.config.yml, you will be prompted for the springboard-build branch.

After composer completes, run `vagrant up`.

The first time running vagrant will take a while.

## What does the template do?

* Drush make will install Springboard, checking out working copies from the springboard git repo.
* The default install will be in `sites/first` and will have Springboard version 7.x-4.x
* Additional sites will be in sites/{docroot}, docroot defined in local.config.yml.
* The Springboard acceptance tests repository will be placed in `tests`. A port has been forwarded from the guests 3306 port to the hosts 3307 port. If you'd like to run the Codeception tests, you'll need to follow the instructions in `web/tests/README.md`, and modify the `web/tests/codeception.yml` file to change the `modules:config:Db:dsn` variable to use `mysql:host=127.0.0.1;dbname=springboard;port=3307`.
* The Springboard-Build repository will be placed in `build`.

## Updating Virtual hosts

If you want to add a new site to a previously provisioned SpringboardVM, then you need to:
* Define it in local.config.yml
* run `composer update`
* run `vagrant provision`


## DrupalVM

More information about DrupalVM can be found at [DrupalVM.com](http://drupalvm.com/), and documentation for DrupalVM can be found at [the DrupalVM docs](http://docs.drupalvm.com/).

DrupalVM will be placed in `vendor/geerlingguy/drupal-vm/`, and configuration files will be available to edit in the `config/` directory. A `config.yml` file is located in `config/`, which is a modified version of DrupalVM's default.config.yml file. Any configuration that needs to be changed for DrupalVM can be done in this file. Additionally, you can place a `local.config.yml` file in this folder to override any settings in `config.yml`, which is useful if you're sharing your VM configuration across teams. A Vagrantfile named `Vagrantfile.local` may also be placed in this directory to override anything in DrupalVM's Vagrantfile.

## Credits

Thanks to [drupal-project](https://github.com/drupal-composer/drupal-project/tree/7.x) for the initial template, [DrupalVM](https://www.drupalvm.com/), [composer-patches](https://github.com/cweagans/composer-patches) for helping manage patches, and [composer-preserve-paths](https://github.com/derhasi/composer-preserve-paths) for helping with path preservation.
