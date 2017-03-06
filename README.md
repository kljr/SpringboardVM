# DruVMoser

A Springboard development environment built with Composer, Drush make, Codeception, DrupalVM,
Ansible and Bash.

Provides multiple fully-configured Springboard sites with working copies
of the Springboard repositories, a dedicated testing site and testing suite, Bash scripts which
allow Drush make to update existing sites' core and contrib modules without touching
their Springboard directories, automatic DB backups from guest to host,
and quick, pain-free provisioning, management and updating of Apache, mySQL and Drupal/Springboard.

## Prerequisites

- Linux or Mac (with NFS, required)
- Composer installed globally, and preferably renamed or aliased in your shell as "composer"".
- Drush installed globally (see Drush notes below)
- VirtualBox 5.1.10 or later (5.0.32 appears to still work on Mac)
- Vagrant 1.8.6 or later
- For acceptance tests, port 3334 open. You can change this port by editing
config/Vagrantfile.local if there is a conflict. (You'll need to update the acceptance tests port config too.)

If you have the following Vagrant plugins, no network/IP configuration is required:

- [vagrant-auto_network](https://github.com/oscar-stack/vagrant-auto_network)
- [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)

Otherwise you will need to edit *vagrant_ip* in `config/local.config.yml`
to assign an IP Address, and update */etc/hosts* on your computer to point
druvmoser.dev and the other domains you
create at the IP of the virtual machine. You can find the correct
information for the hosts file by visiting the DruVMoser's IP address after
install.

For DB backups:

- [vagrant-triggers](https://github.com/emyl/vagrant-triggers)


Also helpful but not required:
- Ansible 2.2.0 or later, for faster provisioning (can be easily installed with Homebrew on a Mac)
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
their vendor dependencies and triggers a bash script which runs drush make and
installs Springboard, checking out git working copies of Springboard
modules, themes and libraries from the Springboard git repo.
* Provisions DrupalVM, Apache and mySQL, creates virtual hosts,
site databases, and installs the Springboard profile.
* Creates two default sites, one a dedicated testing site.
* Configures the acceptance tests to work out of the box.
* Allows additional sites to be automatically installed in
sites/{docroot}, with a docroot and virtual host you define in
config/local.config.yml.
* Automates replacing generic site databases and file assets with
reference site assets.
* Provides shell scripts to allow Drush Make to update Drupal core and
contrib on an existing site without touching its Springboard folders.
* Provides a Drush alias to quickly install and configure developer
modules: `drush dm-prep` installs admin_menu, module_filter, and devel,
and disables toolbar menu, configures devel and the views admin UI, and
sets the admin password to "admin".
* Provides shell aliases and functions to quickly navigate the directory hierarchy and perform tasks.
* Provides automatic DB backups when you halt or destroy the VM, and backups on demand (requires vagrant triggers plugin).
* Creates Drush aliases from host to guest which match your docroot folder name: `drush @#docroot`, allowing you to
keep your aliases short and simple. The "#" is not a typo, it's a configurable prefix which allows you to run multiple
installs of DruVMoser and not have conflicting aliases.

## Updating virtual hosts and adding new sites.

If you want to add a new site to a previously provisioned DruVMoser,
then you need to:
* Define the virtual host entry in local.config.yml
* Run `scripts/make-sb.sh` followed by `scripts/druv-provision.sh` (faster) or `vagrant provision` to update Apache (or nginx) and create the databases and settings files.

Adding too many sites at once can cause PHP timeouts, so be reasonable.

## Updating existing Springboard sites

There are two shell scripts which allow you to update a Springboard site's
Drupal core and contrib modules automatically, without touching
Springboard modules, themes or libraries;

* `scripts/update-cc.sh` prompts you to download a version of Springboard,
and then copies the Springboard folders of your existing site into it,
moves the old site folder into the backups directory, and moves the
updated folder into its place.

* `scripts/update-cc-inverse.sh` copies drupal core and contrib files out of
a new Springboard download and places them into your existing site,
without overwriting Springboard folders or any non-Springboard
customizations in the libraries or contrib folders.

* If you want to replace all code in a site, including any repositories, just delete the document root folder, and
run `scripts/make-sb.sh` followed by `scripts/druv-provision.sh`.

## Replacing default content with reference databases and files

There's not a direct connection to S3, but if you place gzipped files and dbs in
the `artifacts/sites` folder according to the instructions in the
 [readme,](https://github.com/kljr/druvmoser/blob/master/artifacts/README.md)
you can automatically replace any site's files and/or database with those items
 by running `scripts/load-artifact.sh.`

## Symlinking shared repositories

`scripts/symlink.sh` automates the replacing of springboard repositories inside a particular site's folders with
symlinks to shared repositories in the `linked` folder, if that is the way you prefer to work. The default is to use the
repo in the site's directory tree.

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
`scripts/druv-provision.sh` to install a completely new Springboard version,


A port has been forwarded from the guest's 3306 port to the host's 3334
port. If port 3334 is already in use, edit the port in `config/Vagranfile.local`
or create a new `config/Vagrantfile.custom`. You will also have
to edit `acceptance-tests/codeception.yml` to have the alternate port.

##Useful shell aliases and functions

Most of these are available by default on the virtual machine. See templates/bashrc_host for a template formatted to
copy and paste to your computer's .bashrc file.

>Directory switching

* `druv` - Go to DruVMoser install directory.
* `dwdw [docroot/path]` - switch to docroot or any path in a docroot.
* `dwdwm [docroot]` - switch to the Springboard modules directory of site with [docroot]
* `dwdwt [docroot]` - switch to the Springboard themes directory of site with [docroot]
* `dwdwl [docroot]` - switch to the libraries directory of site with [docroot]
* If you're already in a site directory context, the above commands will work without arguments.

* `dwac` - Go to acceptance tests directory

>  Managing sites

* `upcc` - copy your springboard directories into a new springboard download, and replace the original docroot.
* `upccin` -  copy new drupal core and contrib into your existing springboard install.
* `druvpro` - provision virtual hosts for new installations, create the site, the database, and drush aliases.
* `dwbld` - show Springboard version of the build repo
* `dwbld [branch_name]` - switch the springboard build repo to a branch.

> Testing

* `dwac` - Go to acceptance tests directory
* `codecept` - start codeception
* `selchr` - start selenium with chromedriver.

#####These are only available for your host computer.

> Vagrant

* `vlt` - vagrant halt
* `vup` - vagrant up
* `vre` - vagrant reload
* `vsh` - vagrant ssh

> Apache

* `aprel` - restart apache
* `druvpro` - provision virtual hosts for new installations, create the site, database, and drush aliases.

> DB

* `dwdump` - dump all databases to backup

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