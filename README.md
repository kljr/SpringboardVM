# Springboard Crush

Springboard with Composer + Drush Make + DrupalVM.

Creates one or more fully configured Springboard sites, plus a virtual machine to run them in.

## Prerequisites

- Linux or Mac (with NFS)
- Composer
- VirtualBox
- Vagrant
- Ansible (not required, but will make things quicker).

If you have all of the following vagrant plugins, no network/IP configuration is required:

- [vagrant-auto_network](https://github.com/oscar-stack/vagrant-auto_network)
- [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)

Otherwise you will need to edit the vagrant_ip in local.config.yml, and update /etc/hosts to
point springboardvm.dev and the other domains you create at the IP of the virtual machine.

Also helpful:

- [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest)

#Usage

Clone this repository.

If you want to create additional Springboard sites besides the default, copy config/example.local.config.yml to
config/local.config.yml and edit as you see fit.

Run `composer update`

After composer  update completes, run `vagrant up`.

The first time running vagrant will take a while. After all processes complete successfully
you can view the dashboard at dashboard.springboardvm.dev.

## What does Springboard Crush do?

* Composer will download Springboard-Build, DrupalVM, the Acceptance Test repo and their vendor dependencies.
* Composer will then trigger a bash script which runs drush make.
* Drush will install Springboard, checking out git working copies of Springboard modules, themes and libraries from the springboard git repo. The default install will be in `sites/sb_default` and will have Springboard version 7.x-4.x
* Additional sites will be in sites/{docroot}, with the docroot you defined in local.config.yml.
* Vagrant will provision Drupal VM, Apache and mySQL, and create virtual host entries and databases.
* Springboard Crush provides a shell script to allow Drush to update Drupal core and contrib on an existing site without touching its Springboard folders.

## Updating virtual hosts and adding new sites.

If you want to add a new site to a previously provisioned SpringboardVM, then you need to:
* Define it in local.config.yml
* run `scripts/make-sb.sh` (You may have to chmod +x).
* Enter the springboard version you want to download at the prompt
* Wait for the script to complete, then run `vagrant provision` to update apache
and do other post-provision tasks.

## Updating existing Springboard sites

There are two scripts which allow you to update a Springboard site's Drupal core and contrib modules automatically,
without touching Springboard modules, themes or libraries;

* scripts/update-cc.sh prompts you to download a version of Springboard, and then copies
the Springboard folders of your existing site into it, moves the old site folder into backups directory, and moves
the new folder into its place.

* scripts/update-cc-inverse copies drupal core and contrib files out of a new Springboard download and places them into your existing
site, without overwriting Springboard folders or any non-Springboard customizations in the libraries or contrib folders.

## Running tests
The Springboard acceptance tests repository will be placed in `tests`.
A port has been forwarded from the guests 3306 port to the hosts 3307 port, or you can configure mySQL to allow connections from any IP.
If you'd like to run the Codeception tests, you'll need to follow the instructions
in `tests/README.md`, and modify the `tests/codeception.yml` file to change
the `modules:config:Db:dsn` variable to use `mysql:host=127.0.0.1;dbname=springboard;port=3307`.

## DrupalVM

More information about DrupalVM can be found at [DrupalVM.com](http://drupalvm.com/), and documentation for DrupalVM can be found at [the DrupalVM docs](http://docs.drupalvm.com/).

DrupalVM will be placed in `vendor/geerlingguy/drupal-vm/`, and configuration files will be available to edit in the `config/` directory. A `config.yml` file is located in `config/`, which is a modified version of DrupalVM's default.config.yml file. Any configuration that needs to be changed for DrupalVM can be done in this file. Additionally, you can place a `local.config.yml` file in this folder to override any settings in `config.yml`, which is useful if you're sharing your VM configuration across teams. A Vagrantfile named `Vagrantfile.local` may also be placed in this directory to override anything in DrupalVM's Vagrantfile.

## Credits

Thanks to [drupal-project](https://github.com/drupal-composer/drupal-project/tree/7.x) for the initial template, [DrupalVM](https://www.drupalvm.com/), [composer-patches](https://github.com/cweagans/composer-patches) for helping manage patches, and [composer-preserve-paths](https://github.com/derhasi/composer-preserve-paths) for helping with path preservation.
