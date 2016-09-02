dujour
=========

####Table of Contents

1. [Overview - What is the Dujour module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with Dujour module](#setup)
4. [Usage - The classes and parameters available for configuration](#usage)
5. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
7. [Development - Guide for contributing to the module](#development)
8. [Release Notes - Notes on the most recent updates to the module](#release-notes)

Overview
--------
By guiding dujour setup and configuration with a puppet master, the Dujour module provides fast, streamlined access to Puppet Labs products' checkin information.

Module Description
-------------------
The Dujour module provides a quick way to get started using Dujour, a version-checking service for Puppet Labs products. The module will install Dujour if you don't have it. The module will also provide a dashboard, [Appetizer](https://github.com/ajroetker/appetizer), to view checkin analytics.

For more information about Dujour [please see the official Dujour documentation.](https://github.com/puppetlabs/dujour)

Tests
------

To run the dujour puppet module tests, simply type the following below:

```
$ bundle install
....
....
$ bundle exec rake spec
```

That will clone in a fixtures module that is required to run the spec tests for puppetlabs-dujour. If you'd like to see what other commands are available, type `bundle exec rake -T`.

Setup
-----

**What Dujour affects:**

* package/service/configuration files for Dujour
  * **note**: Using the `database_host` class will cause your routes.yaml file to be overwritten entirely (see **Usage** below for options and more information )
* listened-to ports

**Introductory Questions**

To begin using Dujour, you’ll have to make a few decisions:

* Which database back-end should I use?
  * PostgreSQL
  * Embedded database (default)
    * **note:** We suggest using the embedded database only for experimental environments rather than production, as it does not scale well and can cause difficulty in migrating to PostgreSQL.
* Should I run the database on the same node that I run Dujour on?

The answers to those questions will be largely dependent on your answers to questions about your Puppet environment:

* How many nodes are you managing?
* What kind of hardware are you running on?
* Is your current load approaching the limits of your hardware?

Depending on your answers to all of the questions above, you will likely fall under one of these set-up options:

1. [Single Node (Testing and Development)](#single-node-setup)
2. [Multiple Node (Recommended)](#multiple-node-setup)

### Single Node Setup

This approach assumes you will use our default database (HSQLdb) and Dujour on the same node. This setup will be great for a testing or experimental environment. In this case, your manifest will look like:

    node puppet {
      # Configure dujour and its underlying database
      class { 'dujour': }
      class { 'dujour::database::postgresql':
        listen_addresses => 'dujour-postgres',
      }
    }

You can provide some parameters for these classes if you’d like more control, but that is literally all that it will take to get you up and running with the default configuration.

### Multiple Node Setup

This approach is for those who prefer not to install Dujour on the same node as the puppet master. Your environment will be easier to scale if you are able to dedicate hardware to the individual system components. You may even choose to run the dujour server on a different node from the PostgreSQL database that it uses to store its data. So let’s have a look at what a manifest for that scenario might look like:

**This is an example of a very basic 2-node setup for Dujour.**

This node is our puppet node:

    node puppet {
      # Here we configure the node to use Dujour,
      # and tell it that the database user is ‘dujour’
      class { 'dujour':
        database_user => 'dujour',
      }
    }

This node is our postgres server:

    node dujour-postgres {
      # Here we install and configure postgres and the dujour
      # database instance, with a database named 'dujour' and
      # user/password of ‘dujour’
      class { 'dujour::database::postgresql':
        database_name => 'dujour',
        database_user => 'dujour',
        database_password => 'dujour',
      }
    }

This should be all it takes to get a 2-node, distributed installation of Dujour up and running.

### Beginning with Dujour
If you’d prefer to use Dujour’s embedded database rather than PostgreSQL, have a look at the database parameter on the dujour class:

    class { 'dujour':
      database => 'hsqldb',
    }

The embedded database can be useful for testing and very small production environments, but it is not recommended for production environments since it consumes a great deal of memory as your number of nodes increase.

Usage
------

Dujour supports a number of configuration options for configuring the dujour service.

### dujour
The `dujour` class is intended as a high-level abstraction will get you up and running with everything you need (including database setup and management).  For maximum configurability, you may choose not to use this class.  You may prefer to manage your dujour setup on your own.

You must declare the class to use it:

    class { 'dujour': }

**Parameters within `dujour`:**

####`database`

Which database backend to use; legal values are `postgres` or `hsql` (default). The `hsql` db can be used for very small installations or for testing, but is not recommended for use in production environments.

####`database_host`

The hostname or IP address of the database server (defaults to `localhost`; ignored for `hsql` db).

####`database_port`

The port that the database server listens on (defaults to `5432`; ignored for `hsql` db).

####`database_username`

The name of the database user to connect as (defaults to `dujour`; ignored for `hsql` db).

####`database_password`

The password for the database user (defaults to `dujour`; ignored for `hsql` db).

####`database_name`

The name of the database instance to connect to (defaults to `dujour`; ignored for `hsql` db).

####`dujour_package`

The dujour package name in the package manager.

####`dujour_version`

The version of the `dujour` package that should be installed.  You may specify an explicit version number, 'present', or 'latest' (defaults to 'present').

####`dujour_service`

The name of the dujour service.

####`confdir`

The dujour configuration directory (defaults to `/etc/dujour`).

### dujour::database::postgresql
The `dujour::database::postgresql` class manages a postgresql server for use by Dujour. It can manage the postgresql packages and service, as well as creating and managing the dujour database and database user accounts.

    class { 'dujour::database::postgresql':
      database_host => 'my.postgres.host.name',
    }

This defaults to `localhost`. This parameter maps directly to postgresql's `listen_addresses` config option; use a '*' to allow connections on any accessible address.

The class also sets up the dujour database and database user accounts.


Limitations
------------

Currently, Dujour is compatible with:

    Puppet Version: 2.7+

Platforms:
* RHEL6
* Debian6

Development
------------

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)
