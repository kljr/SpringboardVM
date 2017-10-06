# SpringboardVM

A Springboard development environment built with Composer, Codeception, DrupalVM,
Ansible and Bash.

Provides multiple fully-configured Springboard sites, each with working copies
of the Springboard repositories, a dedicated testing site and testing suite, automatic DB backups
from guest to host, and quick, pain-free provisioning, management and updating
 of Apache, mySQL and Drupal/Springboard.

## Prerequisites

- Linux or Mac (with NFS, required)
- Composer.phar installed globally, preferably renamed and moved to /usr/local/bin/composer.
- Drush installed globally (see Drush notes below)
- VirtualBox 5.1.10 or later (5.0.32 appears to still work on Mac)
- Vagrant 1.8.6 or later
- For acceptance tests, port 3334 open. You can change this port by editing
config/Vagrantfile.local if there is a conflict. (You'll need to update the acceptance tests port config too.)
- Ansible 2.2.0 or later, for faster provisioning and the creation of Drush aliases
 on your host computer. SpringboardVM will work without this (it's installed on the VM too),
 but you'll lose the automatic host-to-guest aliases, which are very helpful. On OS X, Ansible is
 easily installed with Homebrew.

If you have the following Vagrant plugins, no network/IP configuration is required:

- [vagrant-auto_network](https://github.com/oscar-stack/vagrant-auto_network)
- [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)

Otherwise you will need to edit *vagrant_ip* in `config/local.config.yml`
to assign an IP Address, and update */etc/hosts* on your computer to point
springboard_vm.dev and the other domains you
create at the IP of the virtual machine. You can find the correct
information for the hosts file by visiting the SpringboardVM's IP address after
install.

For DB backups:

- [vagrant-triggers](https://github.com/emyl/vagrant-triggers)

Also helpful but not required:
- [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest)


# Usage

Clone this repository.

Run `composer update`

After the update completes, run `vagrant up`.

The first time running vagrant will take a while. After all processes complete successfully
you can view the SpringboardVM dashboard at http://dashboard.sbvm.dev.

After the initial install, if you want to create additional Springboard sites besides the two
default sites, copy config/example.local.config.yml to
config/local.config.yml and edit as you see fit.
 Then run `scripts/make-sb.sh` and `scripts/sbvm-provision.sh` in that order.


## What does SpringboardVM do?

* Downloads Springboard-Composer, the Acceptance Test repo, DrupalVM, Codeception and
their vendor dependencies.
* Provisions DrupalVM, Apache and mySQL, creates multiple virtual hosts and
site databases.
* Creates two default sites, one a dedicated testing site.
* Allows additional sites to be automatically installed in
sites/{docroot}, with a docroot and virtual host you define in
config/local.config.yml.
* Configures the acceptance tests to work out of the box.
* Automates replacing generic site databases and file assets with
reference site assets.
* Provides a Drush alias to quickly install and configure developer
modules: `drush dm-prep` installs admin_menu, module_filter, and devel,
and disables toolbar menu, configures devel and the views admin UI, and
sets the admin password to "admin".
* Provides shell aliases and functions to quickly navigate the directory hierarchy and perform tasks.
* Provides automatic DB backups when you halt or destroy the VM, and backups on demand (requires vagrant triggers plugin).
* Creates Drush aliases from host to guest which match your docroot folder name: `drush @#docroot`, allowing you to
keep your aliases short and simple. The "#" is not a typo, it's a configurable prefix which allows you to run multiple
installs of SpringboardVM and not have conflicting aliases.

## Updating virtual hosts and adding new sites.

If you want to add a new site to a previously provisioned SpringboardVM,
then you need to:
* Define the virtual host entry in local.config.yml
* Run `scripts/make-sb.sh` followed by `scripts/sbvm-provision.sh` (faster) or `vagrant provision` to update Apache (or nginx) and create the databases and settings files.

Adding too many sites at once can cause PHP timeouts, so be reasonable.

## Updating existing Springboard sites

* If you want to replace all code in a site, including any repositories, just delete the project root folder, and
run `scripts/make-sb.sh` followed by `scripts/sbvm-provision.sh`.

## Replacing default content with reference databases and files

There's not a direct connection to S3, but if you place gzipped files and dbs in
the `artifacts/sites` folder according to the instructions in the
 [readme,](https://github.com/kljr/springboard_vm/blob/master/artifacts/README.md)
you can automatically replace any site's files and/or database with those items
 by running `scripts/load-artifact.sh.`

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
you may want to test. You can also delete the sb_testing directory, and run `scripts/make-sb.sh` followed by
`scripts/sbvm-provision.sh` to install a completely new Springboard version,


A port has been forwarded from the guest's 3306 port to the host's 3335
port. If port 3335 is already in use, edit the port in `config/Vagranfile.local`
or create a new `config/Vagrantfile.custom` file. You will also have
to edit `acceptance-tests/codeception.yml` to have the alternate port.

## Useful shell aliases and functions

Most of these are available by default on the virtual machine. See templates/bashrc_host for a template formatted to
copy and paste to your computer's .bashrc file.

> Directory switching

* `sbvm` - Go to SpringboardVM install directory.
* `cdcd [docroot/path]` - switch to docroot or any path in a docroot.
* `cdcdm [docroot]` - switch to the Springboard modules directory of site with [docroot]
* `cdcdt [docroot]` - switch to the Springboard themes directory of site with [docroot]
* `cdcdl [docroot]` - switch to the libraries directory of site with [docroot]
* If you're already in a site directory context, the above commands will work without arguments.

* `sbvm_ac` - Go to acceptance tests directory

>  Managing sites

* `sbvm_prov` - provision virtual hosts for new installations, create the site, the database, and drush aliases.

> Testing

* `sbvm_ac` - Go to acceptance tests directory
* `codecept` - start codeception
* `selchr` - start selenium with chromedriver.

##### These are only available for your host computer.

> Vagrant

* `vlt` - vagrant halt
* `vup` - vagrant up
* `vre` - vagrant reload
* `vsh` - vagrant ssh

> Apache

* `aprel` - restart apache
* `sbvm_prov` - provision virtual hosts for new installations, create the site, database, and drush aliases.

> DB

* `sbvm_dump` - dump all databases to backup

## Drush global install

You could install Drush globally with Composer (`composer require global drush/drush`), but that is likely to lead to conflicts
if you have other global projects with conflicting dependencies.

Instead use [cgr](https://github.com/consolidation/cgr) to manage all your global packages
(requires that composer be renamed from "composer.phar" to "composer"
and installed globally, preferably as /usr/local/bin/composer).

Or take the steps below to manually install drush globally:

    php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');" > drush
    php drush core-status
    chmod +x drush
    sudo mv drush /usr/local/bin

##Updating SpringboardVM itself

After you pull the latest changes, run `vagrant reload --provision`

## DrupalVM

More information about DrupalVM can be found at
[DrupalVM.com](http://drupalvm.com/), and documentation for DrupalVM can
be found at [the DrupalVM docs](http://docs.drupalvm.com/).

Drupal VM ships with a firewall. You can disable it by ssh-ing into the
machine and doing `sudo service firewall stop`

A Vagrantfile named `Vagrantfile.custom` can be placed in the config
directory to override or add to DrupalVM's and SpringboardVM's Vagrant files.

## Credits

Thanks to
- [Springboard-Build-Composer](https://github.com/robertromore/Springboard-Build-Composer)
- [Composer template for Drupal projects](https://github.com/drupal-composer/drupal-project/tree/7.x)
- [DrupalVM](https://www.drupalvm.com/)
