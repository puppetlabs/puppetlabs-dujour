dujour
=========

####Table of Contents

1. [Overview - What is the Dujour module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with Dujour module](#setup)
4. [Usage - The classes and parameters available for configuration](#usage)
5. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [Release Notes - Notes on the most recent updates to the module](#release-notes)

Overview
--------
By guiding dujour setup and configuration with a puppet master, the Dujour module provides fast, streamlined access to data on puppetized infrastructure.

Module Description
-------------------
The Dujour module provides a quick way to get started using Dujour, an open source inventory resource service that manages storage and retrieval of platform-generated data. The module will install PostgreSQL and Dujour if you don't have them, as well as set up the connection to puppet master. The module will also provide a dashboard you can use to view the current state of your system.

For more information about Dujour [please see the official Dujour documentation.](http://docs.puppetlabs.com/dujour/)


Setup
-----

**What Dujour affects:**

* package/service/configuration files for Dujour
  * **note**: Using the `database_host` class will cause your routes.yaml file to be overwritten entirely (see **Usage** below for options and more information )
* package/service/configuration files for PostgreSQL (optional, but set as default)
* puppet master's runtime (via plugins)
* puppet master's configuration
* system firewall (optional)
* listened-to ports

**Introductory Questions**

To begin using Dujour, you’ll have to make a few decisions:

* Which database back-end should I use?
  * PostgreSQL (default) or our embedded database
  * Embedded database
    * **note:** We suggest using the embedded database only for experimental environments rather than production, as it does not scale well and can cause difficulty in migrating to PostgreSQL.
* Should I run the database on the same node that I run Dujour on?
* Should I run Dujour on the same node that I run my master on?

The answers to those questions will be largely dependent on your answers to questions about your Puppet environment:

* How many nodes are you managing?
* What kind of hardware are you running on?
* Is your current load approaching the limits of your hardware?

Depending on your answers to all of the questions above, you will likely fall under one of these set-up options:

1. [Single Node (Testing and Development)](#single-node-setup)
2. [Multiple Node (Recommended)](#multiple-node-setup)

### Single Node Setup

This approach assumes you will use our default database (PostgreSQL) and run everything (PostgreSQL, Dujour, puppet master) all on the same node. This setup will be great for a testing or experimental environment. In this case, your manifest will look like:

    node puppetmaster {
      # Configure dujour and its underlying database
      class { 'dujour': }
      # Configure the puppet master to use dujour
      class { 'dujour::master::config': }
    }

You can provide some parameters for these classes if you’d like more control, but that is literally all that it will take to get you up and running with the default configuration.

### Multiple Node Setup

This approach is for those who prefer not to install Dujour on the same node as the puppet master. Your environment will be easier to scale if you are able to dedicate hardware to the individual system components. You may even choose to run the dujour server on a different node from the PostgreSQL database that it uses to store its data. So let’s have a look at what a manifest for that scenario might look like:

**This is an example of a very basic 3-node setup for Dujour.**

This node is our puppet master:

    node puppet {
      # Here we configure the puppet master to use Dujour,
      # and tell it that the hostname is ‘dujour’
      class { 'dujour::master::config':
        dujour_server => 'dujour',
      }
    }

This node is our postgres server:

    node dujour-postgres {
      # Here we install and configure postgres and the dujour
      # database instance, and tell postgres that it should
      # listen for connections to the hostname ‘dujour-postgres’
      class { 'dujour::database::postgresql':
        listen_addresses => 'dujour-postgres',
      }
    }

This node is our main dujour server:

    node dujour {
      # Here we install and configure Dujour, and tell it where to
      # find the postgres database.
      class { 'dujour::server':
        database_host => 'dujour-postgres',
      }
    }

This should be all it takes to get a 3-node, distributed installation of Dujour up and running. Note that, if you prefer, you could easily move two of these classes to a single node and end up with a 2-node setup instead.

### Beginning with Dujour
Whether you choose a single node development setup or a multi-node setup, a basic setup of Dujour will cause: PostgreSQL to install on the node if it’s not already there; Dujour postgres database instance and user account to be created; the postgres connection to be validated and, if successful, Dujour to be installed and configured; Dujour connection to be validated and, if successful, the puppet master config files to be modified to use Dujour; and the puppet master to be restarted so that it will pick up the config changes.

If your logging level is set to INFO or finer, you should start seeing Dujour-related log messages appear in both your puppet master log and your dujour log as subsequent agent runs occur.

If you’d prefer to use Dujour’s embedded database rather than PostgreSQL, have a look at the database parameter on the dujour class:

    class { 'dujour':
      database => 'embedded',
    }

The embedded database can be useful for testing and very small production environments, but it is not recommended for production environments since it consumes a great deal of memory as your number of nodes increase.

### Cross-node Dependencies

It is worth noting that there are some cross-node dependencies, which means that the first time you add the module's configurations to your manifests, you may see a few failed puppet runs on the affected nodes.

Dujour handles cross-node dependencies by taking a sort of “eventual consistency” approach. There’s nothing that the module can do to control the order in which your nodes check in, but the module can check to verify that the services it depends on are up and running before it makes configuration changes--so that’s what it does.

When your puppet master node checks in, it will validate the connectivity to the dujour server before it applies its changes to the puppet master config files. If it can’t connect to dujour, then the puppet run will fail and the previous config files will be left intact. This prevents your master from getting into a broken state where all incoming puppet runs fail because the master is configured to use a dujour server that doesn’t  exist yet. The same strategy is used to handle the dependency between the dujour server and the postgres server.

Hence the failed puppet runs. These failures should be limited to 1 failed run on the dujour node, and up to 2 failed runs on the puppet master node. After that, all of the dependencies should be satisfied and your puppet runs should start to succeed again.

You can also manually trigger puppet runs on the nodes in the correct order (Postgres, Dujour, puppet master), which will avoid any failed runs.

Usage
------

Dujour supports a large number of configuration options for both configuring the dujour service and connecting that service to the puppet master.

### dujour
The `dujour` class is intended as a high-level abstraction (sort of an 'all-in-one' class) to help simplify the process of getting your dujour server up and running. It wraps the slightly-lower-level classes `dujour::server` and `dujour::database::*`, and it'll get you up and running with everything you need (including database setup and management) on the server side.  For maximum configurability, you may choose not to use this class.  You may prefer to use the `dujour::server` class directly, or manage your dujour setup on your own.

You must declare the class to use it:

    class { 'dujour': }

**Parameters within `dujour`:**

####`listen_address`

The address that the web server should bind to for HTTP requests (defaults to `localhost`.'0.0.0.0' = all).

####`listen_port`

The port on which the dujour web server should accept HTTP requests (defaults to '8080').

####`open_listen_port`

If true, open the http_listen\_port on the firewall (defaults to false).

####`ssl_listen_address`

The address that the web server should bind to for HTTPS requests (defaults to `$::clientcert`). Set to '0.0.0.0' to listen on all addresses.

####`ssl_listen_port`

The port on which the dujour web server should accept HTTPS requests (defaults to '8081').

####`disable_ssl`

If true, the dujour web server will only serve HTTP and not HTTPS requests (defaults to false).

####`open_ssl_listen_port`

If true, open the ssl_listen\_port on the firewall (defaults to true).

####`database`

Which database backend to use; legal values are `postgres` (default) or `embedded`. The `embedded` db can be used for very small installations or for testing, but is not recommended for use in production environments. For more info, see the [dujour docs](http://docs.puppetlabs.com/dujour/).

####`database_port`

The port that the database server listens on (defaults to `5432`; ignored for `embedded` db).

####`database_username`

The name of the database user to connect as (defaults to `dujour`; ignored for `embedded` db).

####`database_password`

The password for the database user (defaults to `dujour`; ignored for `embedded` db).

####`database_name`

The name of the database instance to connect to (defaults to `dujour`; ignored for `embedded` db).

####`node_ttl`

The length of time a node can go without receiving any new data before it's automatically deactivated.  (defaults to '0', which disables auto-deactivation). This option is supported in Dujour >= 1.1.0.

####`node_purge_ttl`

The length of time a node can be deactivated before it's deleted from the database. (defaults to '0', which disables purging). This option is supported in Dujour >= 1.2.0.

####`report_ttl`

The length of time reports should be stored before being deleted. (defaults to '7d', which is a 7-day period). This option is supported in Dujour >= 1.1.0.

####`dujour_package`

The dujour package name in the package manager.

####`dujour_version`

The version of the `dujour` package that should be installed.  You may specify an explicit version number, 'present', or 'latest' (defaults to 'present').

####`dujour_service`

The name of the dujour service.

####`manage_redhat_firewall`

*DEPRECATED: Use open_ssl_listen_port instead.*

Supports a Boolean of true or false, indicating whether or not the module should open a port in the firewall on RedHat-based systems.  Defaults to `false`.  This parameter is likely to change in future versions. Possible changes include support for non-RedHat systems and finer-grained control over the firewall rule (currently, it simply opens up the postgres port to all TCP connections).

####`confdir`

The dujour configuration directory (defaults to `/etc/dujour/conf.d`).

####`java_args`

Java VM options used for overriding default Java VM options specified in Dujour package (defaults to `{}`). See [Dujour Configuration](http://docs.puppetlabs.com/dujour/1.1/configure.html) to get more details about the current defaults.

Example: to set `-Xmx512m -Xms256m` options use `{ '-Xmx' => '512m', '-Xms' => '256m' }`

### dujour:server

The `dujour::server` class manages the dujour server independently of the underlying database that it depends on. It will manage the dujour package, service, config files, etc., but will still allow you to manage the database (e.g. postgresql) however you see fit.

    class { 'dujour::server':
      database_host => 'dujour-postgres',
    }

**Parameters within `dujour::server`:**

Uses the same parameters as `dujour`, with one addition:

####`database_host`

The hostname or IP address of the database server (defaults to `localhost`; ignored for `embedded` db).

### dujour::master::config

The `dujour::master::config` class directs your puppet master to use Dujour, which means that this class should be used on your puppet master node. It’ll verify that it can successfully communicate with your dujour server, and then configure your master to use Dujour.

Using this class involves allowing the module to manipulate your puppet configuration files; in particular: puppet.conf and routes.yaml. The puppet.conf changes are supplemental and should not affect any of your existing settings, but the routes.yaml file will be overwritten entirely. If you have an existing routes.yaml file, you will want to take care to use the manage_routes parameter of this class to prevent the module from managing that file, and you’ll need to manage it yourself.

    class { 'dujour::master::config':
      dujour_server => 'my.host.name',
      dujour_port   => 8081,
    }

**Parameters within `dujour::master::config`:**

####`dujour_server`

The dns name or ip of the dujour server (defaults to the certname of the current node).

####`dujour_port`

The port that the dujour server is running on (defaults to 8081).

####`manage_routes`

If true, the module will overwrite the puppet master's routes file to configure it to use Dujour (defaults to true).

####`manage_storeconfigs`

If true, the module will manage the puppet master's storeconfig settings (defaults to true).

####`manage_report_processor`

If true, the module will manage the 'reports' field in the puppet.conf file to enable or disable the dujour report processor.  Defaults to 'false'.

####`manage_config`
If true, the module will store values from dujour_server and dujour_port parameters in the dujour configuration file.
If false, an existing dujour configuration file will be used to retrieve server and port values.

####`strict_validation`
If true, the module will fail if dujour is not reachable, otherwise it will preconfigure dujour without checking.

####`enable_reports`

Ignored unless `manage_report_processor` is `true`, in which case this setting will determine whether or not the dujour report processor is enabled (`true`) or disabled (`false`) in the puppet.conf file.

####`puppet_confdir`

Puppet's config directory (defaults to `/etc/puppet`).

####`puppet_conf`

Puppet's config file (defaults to `/etc/puppet/puppet.conf`).

####`dujour_version`

The version of the `dujour` package that should be installed. You may specify an explicit version number, 'present', or 'latest' (defaults to 'present').

####`dujour_startup_timeout`

The maximum amount of time that the module should wait for Dujour to start up. This is most important during the initial install of Dujour (defaults to 15 seconds).

####`restart_puppet`

If true, the module will restart the puppet master when Dujour configuration files are changed by the module.  The default is 'true'.  If set to 'false', you must restart the service manually in order to pick up changes to the config files (other than `puppet.conf`).

### dujour::database::postgresql
The `dujour::database::postgresql` class manages a postgresql server for use by Dujour. It can manage the postgresql packages and service, as well as creating and managing the dujour database and database user accounts.

    class { 'dujour::database::postgresql':
      listen_addresses => 'my.postgres.host.name',
    }

The `listen_address` is a comma-separated list of hostnames or IP addresses on which the postgres server should listen for incoming connections. This defaults to `localhost`. This parameter maps directly to postgresql's `listen_addresses` config option; use a '*' to allow connections on any accessible address.

### dujour::database::postgresql_db
The `dujour::database::postgresql_db` class sets up the dujour database and database user accounts. This is included from the `dujour::database::postgresql` class but can be used on its own if you want to use your own classes to configure the postgresql server itself in a way that the `dujour::database::postgresql` doesn't support.

Implementation
---------------

### Resource overview

In addition to the classes and variables mentioned above, Dujour includes:

**dujour::master::routes**

Configures the puppet master to use Dujour as the facts terminus. *WARNING*: the current implementation simply overwrites your routes.yaml file; if you have an existing routes.yaml file that you are using for other purposes, you should *not* use this.

    class { 'dujour::master::routes':
      puppet_confdir => '/etc/puppet'
    }

**dujour::master::storeconfigs**

Configures the puppet master to enable storeconfigs and to use Dujour as the storeconfigs backend.

    class { 'dujour::master::storeconfigs':
      puppet_conf => '/etc/puppet/puppet.conf'
    }

**dujour::server::database_ini**

Manages Dujour's `database.ini` file.

    class { 'dujour::server::database_ini':
      database_host     => 'my.postgres.host',
      database_port     => '5432',
      database_username => 'dujour_pguser',
      database_password => 'dujour_pgpasswd',
      database_name     => 'dujour',
    }

**dujour::server::validate_db**

Validates that a successful database connection can be established between the node on which this resource is run and the specified dujour database instance (host/port/user/password/database name).

    dujour::server::validate_db { 'validate my dujour database connection':
      database_host     => 'my.postgres.host',
      database_username => 'mydbuser',
      database_password => 'mydbpassword',
      database_name     => 'mydbname',
    }

### Custom Types

**dujour_conn_validator**

Verifies that a connection can be successfully established between a node and the dujour server. Its primary use is as a precondition to prevent configuration changes from being applied if the dujour server cannot be reached, but it could potentially be used for other purposes such as monitoring.

Limitations
------------

Currently, Dujour is compatible with:

    Puppet Version: 2.7+

Platforms:
* RHEL6
* Debian6
* Ubuntu 10.04

Development
------------

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)
