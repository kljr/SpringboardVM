# DruVMoser

A Springboard development environment built with Composer, Drush make, Codeception, DrupalVM,
Ansible and Bash.

Provides multiple fully-configured Springboard sites with working copies
of the Springboard repositories, a dedicated testing site and testing suite, bash scripts which
allow Drush make to update existing sites' core and contrib modules without touching
their Springboard directories, and quick, pain-free provisioning, management and updating
of Apache, mySQL and Drupal/Springboard.

## Prerequisites

- Linux or Mac (with NFS, required)
- Composer installed globally, and preferably renamed or aliased in your shell as "composer"".
- Drush installed globally (see Drush notes below)
- VirtualBox
- Vagrant
- Ansible (Can be easily installed with Homebrew on a Mac)
- For acceptance tests, port 3334 open.

If you have the following Vagrant plugins, no network/IP configuration is required:

- [vagrant-auto_network](https://github.com/oscar-stack/vagrant-auto_network)
- [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)

Otherwise you will need to edit the vagrant_ip in local.config.yml, and
update /etc/hosts to point druvmoser.dev and the other domains you
create at the IP of the virtual machine. You can find the correct
information for the hosts file by visiting the VM IP address after
install.

For DB backups:

- [vagrant-triggers](https://github.com/emyl/vagrant-triggers)


Also helpful but not required:

- [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest)


#Usage

Clone this repository.

If you want to create additional Springboard sites besides the two
default sites, copy config/example.local.config.yml to
config/local.config.yml and edit as you see fit.

Run `composer update`

After the update completes, run `vagrant up`.

The first time running vagrant will take a while. After all processes complete successfully
you can view the DruVMoser dashboard at http://dashboard.druvmoser.dev.

## What does DruVMoser do?

* Downloads Springboard-Build, the Acceptance Test repo, DrupalVM, Codeception and
their vendor dependencies.
* Triggers a bash script which runs drush make.
* Installs Springboard, checking out git working copies of Springboard
modules, themes and libraries from the Springboard git repo. The default
sites will be in `sites/sb_default` and `sites/sb_test,` and will have
Springboard version 7.x-4.x.
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
* Provides shell aliases to quickly navigate the directory hierarchy and perform tasks.
* Provides automatic DB backups when you halt or destroy the VM, and backups on demand (requires vagrant triggers plugin).
* Creates short drush aliases from host to guest which match your docroot folder name: `drush @#docroot`. The "#" is not a typo

## Updating virtual hosts and adding new sites.

If you want to add a new site to a previously provisioned DruVMoser,
then you need to:
* Define the virtual host entry in local.config.yml
* Run `scripts/make-sb.sh` (faster) or `composer update` (You may have to chmod the +x the script). Enter the
springboard version you want to download at the prompt.
* Wait for the make script to complete, then run `scripts/apache-provision.sh` (faster)
 or `vagrant provision` to update Apache and create the databases and settings files.

## Updating existing Springboard sites

There are two shell scripts which allow you to update a Springboard site's
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

* If you want to replace all code in a site, including any repositories, just delete the document root folder, and
run `scripts/make-sb.sh`, and then `scripts/apache-provision.sh`.

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

##Useful shell aliases and functions

Most of these are available by default on the virtual machine. See templates/bashrc_host for a template formatted for
copying and pasting to your computer's .bashrc file.

>Directory switching

* druv -  go to DruvMoser root.
* drac - Go to acceptance tests directory
* drsp [docroot] - switch to the Springboard modules directory of site with [docroot]
* drspt [docroot] - switch to the Springboard themes directory of site with [docroot]
* drspl [docroot] - switch to the libraries directory of site with [docroot]
* drbld - show Springboard version of the build directory
* drbld [branch_name] - switch the springboard build repo to a branch.


>  Managing sites

* upcc - copy your springboard directories into a new springboard download, and replace the original directory.
* upccin -  copy new drupal core and contrib into your existing springboard install.
* make-sb - create a new site and database after defining a new virtual host entry.

> Testing

* drac - Go to acceptance tests directory
* codecept - start codeception
* selchr - start selenium with chromedriver.

#####These are only available for your host computer.

> Vagrant

* vlt - vagrant halt
* vup - vagrant up
* vre - vagrant reload
* vsh - vagrant ssh

> Apache

* aprel - restart apache
* appro - provision new vhosts and site databases

 > DB

* drdump - dump all databases to backup

##Drush global install

You could install Drush globally with Composer (`composer require global drush/drush`), but that is likely to lead to conflicts
if you have other global projects with conflicting dependencies.

Instead use [cgr](https://github.com/consolidation/cgr) to manage all your global packages, or take the steps below:

    php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');" > drush
    php drush core-status
    chmod +x drush
    sudo mv drush /usr/local/bin

##Updating DruVMoser itself

After you pull the latest changes, run `vagrant reload --provision`

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
- [Springboard-Build-Composer](https://github.com/robertromore/Springboard-Build-Composer)
- [Composer template for Drupal projects](https://github.com/drupal-composer/drupal-project/tree/7.x)
- [DrupalVM](https://www.drupalvm.com/)

#### Why not just use Composer?

Drush make is on the way out, but Springboard uses drush makefiles. If there was a versioned composer.json equivalent
to Springboard's makefiles, it would be fairly simple to convert to using `composer create-project jacksonriver/springboard`
as basis for triggering multiple new builds, rather than `drush make springboard-mtsb.make`.