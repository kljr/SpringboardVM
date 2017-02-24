# DruVMoser

Springboard with Composer + Drush Make + DrupalVM + Codeception.

Provides multiple fully-configured Springboard sites with working copies
of the Springboard repositories, a dedicated testing site and
environment, scripts that allow Drush Make to update existing sites'
core and contrib modules without touching their Springboard directories,
and a virtual machine to run them in.

## Prerequisites

- Linux or Mac (with NFS, required)
- Composer installed globally, and preferably renamed or aliased in your shell as "composer"".
- VirtualBox
- Vagrant
- Ansible (not required, but will make things quicker. Can be easily installed with Homebrew on a Mac)
- For acceptance tests, port 3334 open.

If you have the following Vagrant plugins, no network/IP configuration is required:

- [vagrant-auto_network](https://github.com/oscar-stack/vagrant-auto_network)
- [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)

Otherwise you will need to edit the vagrant_ip in local.config.yml, and
update /etc/hosts to point druvmoser.dev and the other domains you
create at the IP of the virtual machine. You can find the correct
information for the hosts file by visiting the VM IP address after
install.

Also helpful:

- [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest)
- [vagrant-triggers](https://github.com/emyl/vagrant-triggers)

#Usage

Clone this repository.

If you want to create additional Springboard sites besides the two
default sites, copy config/example.local.config.yml to
config/local.config.yml and edit as you see fit.

Run `composer update`

After the update completes, run `vagrant up`.

The first time running vagrant will take a while. After all processes complete successfully
you can view the dashboard at dashboard.druvmoser.dev.

## What does DruVMoser do?

* Downloads Springboard-Build, DrupalVM, the Acceptance Test repo and
their vendor dependencies.
* Triggers a bash script which runs drush make.
* Installs Springboard, checking out git working copies of Springboard
modules, themes and libraries from the Springboard git repo. The default
install will be in `sites/sb_default` and `sites/sb_test,` and will have
Springboard version 7.x-4.x
* Provisions DrupalVM, Apache and mySQL, creates virtual host entries,
site databases, and installs the Springboard profile.
* Allows additional sites to be automatically installed in
sites/{docroot}, with a docroot and virtual host you define in
config/local.config.yml.
* Provides shell scripts to allow Drush Make to update Drupal core and
contrib on an existing site without touching its Springboard folders.
* Configures the acceptance tests to work out of the box.
* Provides a Drush alias to quickly install and configure developer
modules: `drush dm-prep` installs admin_menu, module_filter, and devel,
and disables toolbar menu, configures devel and the views admin UI, and
sets the admin password to "admin".

## Updating virtual hosts and adding new sites.

If you want to add a new site to a previously provisioned DruVMoser,
then you need to:
* Define the virtual host entry in local.config.yml
* Run `scripts/make-sb.sh` (You may have to chmod +x). Enter the
springboard version you want to download at the prompt.
* Wait for the script to complete, then run `vagrant provision` to
update Apache and create the databases and settings files.

## Updating existing Springboard sites

There are two scripts which allow you to update a Springboard site's
Drupal core and contrib modules automatically, without touching
Springboard modules, themes or libraries;

* scripts/update-cc.sh prompts you to download a version of Springboard,
and then copies the Springboard folders of your existing site into it,
moves the old site folder into the backups directory, and moves the
updated folder into its place.

* scripts/update-cc-inverse copies drupal core and contrib files out of
a new Springboard download and places them into your existing site,
without overwriting Springboard folders or any non-Springboard
customizations in the libraries or contrib folders.

## Running tests

Configuration templates for codeception are copied from the
templates/tests directory into the acceptance test repository. They
should be ready to go.

If the install script was unable to find Composer, run `composer update`
from the /acceptance-tests directory to install Codeception's
dependencies.

Then `vendor/bin/codecept run`

You can use one virtual host exclusively for running tests. The shell
scripts will make it easy to switch among different Springboard versions
you may want to test. You can also delete the sb_testing directory, run
`scripts/make-sb.sh` to install a completely new Springboard version,
then run `vagrant provision` to recreate the settings.php file.

A port has been forwarded from the guest's 3306 port to the host's 3334
port. If port 3334 is already in use, edit config/vagranfile.local to
use a different one. You will also have to edit the acceptance test
configuration to get them to work on an alternate port.

#Useful shell aliases

Add these to your .profile or .bash_profile:

> Directory switching

- alias druv='cd /Path/to/druvmoser'


    function drac(){
        cd /Path/to/druvmoser/acceptance-tests
    }

    function drsp(){
        cd /Path/to/druvmoser/sites/$1/sites/all/modules/springboard
    }
    ex: drsp sb_default


> Vagrant

- alias vlt='vagrant halt'
- alias vup='vagrant up'
- alias vre='vagrant reload'
- alias vsh='vagrant ssh'

> Executables
- alias upcc='/Path/to/druvmoser/scripts/update-cc.sh'
- alias upccin='/Path/to/druvmoser/scripts/update-cc-inverse.sh'
- alias make-sb='/Path/to/druvmoser/scripts/make-sb.sh'
- alias codecept=/Path/to/druvmoser/acceptance-tests/vendor/bin/codecept
- alias selchr='java -jar /Path/to/selenium-server-standalone-2.53.1.jar -Dwebdriver.chrome.driver="/usr/local/bin/chromedriver"'

## DrupalVM

More information about DrupalVM can be found at
[DrupalVM.com](http://drupalvm.com/), and documentation for DrupalVM can
be found at [the DrupalVM docs](http://docs.drupalvm.com/).

Drupal VM ships with a firewall. You can disable it by ssh-ing into the
machine and doing `sudo service firewall stop`

A Vagrantfile named `Vagrantfile.local` is placed in the config
directory to override anything in DrupalVM's Vagrantfile.

## Credits

Thanks to
[Springboard-Build-Composer](https://github.com/robertromore/Springboard
-Build-Composer), [Composer template for Drupal
projects](https://github.com/drupal-composer/drupal-project/tree/7.x)
for the initial template, and [DrupalVM](https://www.drupalvm.com/)
