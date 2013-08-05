# Class: dujour::server
#
# This class provides a simple way to get a dujour instance up and running
# with minimal effort.  It will install and configure all necessary packages for
# the dujour server, but will *not* manage the database (e.g., postgres) server
# or instance (unless you are using the embedded database, in which case there
# is not much to manage).
#
# This class is intended as a high-level abstraction to help simplify the process
# of getting your dujour server up and running; it manages the dujour
# package and service, as well as several dujour configuration files.  For
# maximum configurability, you may choose not to use this class.  You may prefer to
# manage the dujour package / service on your own, and perhaps use the
# individual classes inside of the `dujour::server` namespace to manage some
# or all of your configuration files.
#
# In addition to this class, you'll need to configure your dujour postgres
# database if you are using postgres.  You can optionally do by using the
# `dujour::database::postgresql` class.
#
# You'll also need to configure your puppet master to use dujour.  You can
# use the `dujour::master::config` class to accomplish this.
#
# Parameters:
#   ['listen_address']     - The address that the web server should bind to
#                            for HTTP requests.  (defaults to `localhost`.)
#                            Set to '0.0.0.0' to listen on all addresses.
#   ['listen_port']        - The port on which the dujour web server should
#                            accept HTTP requests (defaults to 8080).
#   ['open_listen_port']   - If true, open the http listen port on the firewall.
#                            (defaults to false).
#   ['ssl_listen_address'] - The address that the web server should bind to
#                            for HTTPS requests.  (defaults to `$::fqdn`.)
#                            Set to '0.0.0.0' to listen on all addresses.
#   ['ssl_listen_port']    - The port on which the dujour web server should
#                            accept HTTPS requests (defaults to 8081).
#   ['disable_ssl']        - If true, disable HTTPS and only serve
#                            HTTP requests. Defaults to false.
#   ['open_ssl_listen_port'] - If true, open the ssl listen port on the firewall.
#                            (defaults to true).
#   ['database']           - Which database backend to use; legal values are
#                            `postgres` (default) or `embedded`.  (The `embedded`
#                            db can be used for very small installations or for
#                            testing, but is not recommended for use in production
#                            environments.  For more info, see the dujour docs.)
#   ['database_host']      - The hostname or IP address of the database server.
#                            (defaults to `localhost`; ignored for `embedded` db)
#   ['database_port']      - The port that the database server listens on.
#                            (defaults to `5432`; ignored for `embedded` db)
#   ['database_username']  - The name of the database user to connect as.
#                            (defaults to `dujour`; ignored for `embedded` db)
#   ['database_password']  - The password for the database user.
#                            (defaults to `dujour`; ignored for `embedded` db)
#   ['database_name']      - The name of the database instance to connect to.
#                            (defaults to `dujour`; ignored for `embedded` db)
#   ['dujour_package']   - The dujour package name in the package manager
#   ['dujour_version']   - The version of the `dujour` package that should
#                            be installed.  You may specify an explicit version
#                            number, 'present', or 'latest'.  Defaults to
#                            'present'.
#   ['dujour_service']   - The name of the dujour service.
#   ['manage_redhat_firewall'] - DEPRECATED: Use open_ssl_listen_port instead.
#                            boolean indicating whether or not the module
#                            should open a port in the firewall on redhat-based
#                            systems.  Defaults to `true`.  This parameter is
#                            likely to change in future versions.  Possible
#                            changes include support for non-RedHat systems and
#                            finer-grained control over the firewall rule
#                            (currently, it simply opens up the postgres port to
#                            all TCP connections).
#   ['confdir']            - The dujour configuration directory; defaults to
#                            `/etc/dujour/conf.d`.
#   ['java_args']          - Java VM options used for overriding default Java VM
#                            options specified in Dujour package.
#                            (defaults to `{}`).
#                            e.g. { '-Xmx' => '512m', '-Xms' => '256m' }
# Actions:
# - Creates and manages a dujour server
#
# Requires:
# - `inkling/postgresql`
#
# Sample Usage:
#     class { 'dujour::server':
#         database_host     => 'dujour-postgres',
#     }
#
class dujour::server(
  $listen_address          = $dujour::params::listen_address,
  $listen_port             = $dujour::params::listen_port,
  $open_listen_port        = $dujour::params::open_listen_port,
  $ssl_listen_address      = $dujour::params::ssl_listen_address,
  $ssl_listen_port         = $dujour::params::ssl_listen_port,
  $disable_ssl             = $dujour::params::disable_ssl,
  $open_ssl_listen_port    = $dujour::params::open_ssl_listen_port,
  $database                = $dujour::params::database,
  $database_host           = $dujour::params::database_host,
  $database_port           = $dujour::params::database_port,
  $database_username       = $dujour::params::database_username,
  $database_password       = $dujour::params::database_password,
  $database_name           = $dujour::params::database_name,
  $node_ttl                = $dujour::params::node_ttl,
  $node_purge_ttl          = $dujour::params::node_purge_ttl,
  $report_ttl              = $dujour::params::report_ttl,
  $dujour_package        = $dujour::params::dujour_package,
  $dujour_version        = $dujour::params::dujour_version,
  $dujour_service        = $dujour::params::dujour_service,
  $manage_redhat_firewall  = $dujour::params::manage_redhat_firewall,
  $confdir                 = $dujour::params::confdir,
  $java_args               = {}
) inherits dujour::params {

  package { $dujour_package:
    ensure => $dujour_version,
    notify => Service[$dujour_service],
  }

  class { 'dujour::server::firewall':
    http_port              => $listen_port,
    open_http_port         => $open_listen_port,
    manage_redhat_firewall => $manage_redhat_firewall
  }

  class { 'dujour::server::database_ini':
    database          => $database,
    database_host     => $database_host,
    database_port     => $database_port,
    database_username => $database_username,
    database_password => $database_password,
    database_name     => $database_name,
    confdir           => $confdir,
    notify            => Service[$dujour_service],
  }

  class { 'dujour::server::jetty_ini':
    listen_address      => $listen_address,
    listen_port         => $listen_port,
    confdir             => $confdir,
    notify              => Service[$dujour_service],
  }

  if !empty($java_args) {

    create_resources(
      'ini_subsetting',
      dujour_create_subsetting_resource_hash(
        $java_args,
        { ensure  => present,
          section => '',
          key_val_separator => '=',
          path => $dujour::params::dujour_initconf,
          setting => 'JAVA_ARGS',
          require => Package[$dujour_package],
          notify => Service[$dujour_service],
        })
    )
  }

  service { $dujour_service:
    ensure => running,
    enable => true,
  }

  Package[$dujour_package] ->
  Class['dujour::server::firewall'] ->
  Class['dujour::server::database_ini'] ->
  Class['dujour::server::jetty_ini'] ->
  Service[$dujour_service]
}
