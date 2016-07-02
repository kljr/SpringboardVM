# Composer template for Springboard projects

This project template should provide a kickstart for managing your site
dependencies with [Composer](https://getcomposer.org/).

If you want to know how to use it as replacement for
[Drush Make](https://github.com/drush-ops/drush/blob/master/docs/make.md) visit
the [Documentation on drupal.org](https://www.drupal.org/node/2471553).

## Usage

First you need to [install composer](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx).

> Note: The instructions below refer to the [global composer installation](https://getcomposer.org/doc/00-intro.md#globally).
You might need to replace `composer` with `php composer.phar` (or similar) for your setup.

After that you can create the project:

```
composer create-project drupal-composer/drupal-project:7.x-dev some-dir --stability dev --no-interaction
```

With `composer require ...` you can download new dependencies to your installation.

```
cd some-dir
composer require drupal/ctools:7.*
```

## Recommended Plugins

For Vagrant, it's recommended to install the following plugins:
- [vagrant-auto_network](https://github.com/oscar-stack/vagrant-auto_network)
- [vagrant-cachier](https://github.com/fgrehm/vagrant-cachier)
- [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)
- [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest)

For Composer, the following plugins are recommended:
- [prestissimo](https://github.com/hirak/prestissimo)

## What does the template do?

When installing the given `composer.json` some tasks are taken care of:

* Drupal will be installed in the `web`-directory.
* DrupalVM will be installed in your vendor directory.
* Modules (packages of type `drupal-module`) will be placed in `web/sites/all/modules/contrib/`
* Springboard modules will be placed in `web/sites/all/modules/springboard/`
* Theme (packages of type `drupal-module`) will be placed in `web/sites/all/themes/contrib/`
* Springboard themes will be placed in `web/sites/all/themes/springboard/`
* Profiles (packages of type `drupal-profile`) will be placed in `web/profiles/`
* The Springboard profile will be placed in `web/profiles/sbsetup/`

## DrupalVM

More information about DrupalVM can be found at [DrupalVM.com](http://drupalvm.com/), and documentation for DrupalVM can be found at [the DrupalVM docs](http://docs.drupalvm.com/).

DrupalVM will be placed in `vendor/geerlingguy/drupal-vm/`, and configuration files will be available to edit in the `config/` directory. A `config.yml` file is located in `config/`, which is a modified version of DrupalVM's default.config.yml file. Any configuration that needs to be changed for DrupalVM can be done in this file. Additionally, you can place a `local.config.yml` file in this folder to override any settings in `config.yml`, which is useful if you're sharing your VM configuration across teams.

## Generate composer.json from existing project

With using [the "Composer Generate" drush extension](https://www.drupal.org/project/composer_generate)
you can now generate a basic `composer.json` file from an existing project. Note
that the generated `composer.json` might differ from this project's file.


## FAQ

### Should I commit the contrib modules I download

Composer recommends **no**. They provide [argumentation against but also workrounds if a project decides to do it anyway](https://getcomposer.org/doc/faqs/should-i-commit-the-dependencies-in-my-vendor-directory.md).
