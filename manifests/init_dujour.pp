# Class: dujour
#
# This class provides a simple way to get a dujour instance up and running
# with minimal effort.  It will install and configure all necessary packages,
# including the database server and instance.
#
# This class is intended as a high-level abstraction to help simplify the process
# of getting your dujour server up and running; it wraps the slightly-lower-level
# classes `dujour::server` and `dujour::database::*`.  For maximum
# configurability, you may choose not to use this class.  You may prefer to
# use the `dujour::server` class directly, or manage your dujour setup on your
# own.
#
# In addition to this class, you'll need to configure your puppet master to use
# dujour.  You can use the `dujour::master::config` class to accomplish this.
#
# Parameters:
#   ['listen_address']     - The address that the web server should bind to
#                            for HTTP requests.  (defaults to `localhost`.
#                            '0.0.0.0' = all)
#   ['listen_port']        - The port on which the dujour web server should
#                            accept HTTP requests (defaults to 8080).
#   ['open_listen_port']   - If true, open the http listen port on the firewall.
#                            (defaults to false).
#   ['database']           - Which database backend to use; legal values are
#                            `postgres` (default) or `embedded`.  (The `embedded`
#                            db can be used for very small installations or for
#                            testing, but is not recommended for use in production
#                            environments.  For more info, see the dujour docs.)
#   ['database_port']      - The port that the database server listens on.
#                            (defaults to `5432`; ignored for `embedded` db)
#   ['database_username']  - The name of the database user to connect as.
#                            (defaults to `dujour`; ignored for `embedded` db)
#   ['database_password']  - The password for the database user.
#                            (defaults to `dujour`; ignored for `embedded` db)
#   ['database_name']      - The name of the database instance to connect to.
#                            (defaults to `dujour`; ignored for `embedded` db)
#   ['open_postgres_port'] - If true, open the postgres port on the firewall.
#                            (defaults to true).
#   ['dujour_package']   - The dujour package name in the package manager
#   ['dujour_version']   - The version of the `dujour` package that should
#                            be installed.  You may specify an explicit version
#                            number, 'present', or 'latest'.  (defaults to
#                            'present')
#   ['dujour_service']   - The name of the dujour service.
#   ['manage_redhat_firewall'] - DEPRECATED: Use open_ssl_listen_port instead.
#                            boolean indicating whether or not the module
#                            should open a port in the firewall on redhat-based
#                            systems.  Defaults to `false`.  This parameter is
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
# - Creates and manages a dujour server and its database server/instance.
#
# Requires:
# - `inkling/postgresql`
#
# Sample Usage:
#   include dujour
#
class dujour(
  $listen_address            = $dujour::params::listen_address,
  $listen_port               = $dujour::params::listen_port,
  $open_listen_port          = $dujour::params::open_listen_port,
  $database                  = $dujour::params::database,
  $database_port             = $dujour::params::database_port,
  $database_username         = $dujour::params::database_username,
  $database_password         = $dujour::params::database_password,
  $database_name             = $dujour::params::database_name,
  $dujour_package            = $dujour::params::dujour_service,
  $dujour_version            = $dujour::params::dujour_version,
  $dujour_service            = $dujour::params::dujour_service,
  $open_postgres_port        = $dujour::params::open_postgres_port,
  $manage_redhat_firewall    = $dujour::params::manage_redhat_firewall,
  $confdir                   = $dujour::params::confdir,
  $java_args                 = {}
) inherits dujour::params {

  if ($manage_redhat_firewall != undef) {
    notify {'Deprecation notice: `$manage_redhat_firewall` has been deprecated in `dujour` class and will be removed in a future version. Use $open_ssl_listen_port and $open_postgres_port instead.':}
  }

  class { 'dujour::server':
    listen_address         => $listen_address,
    listen_port            => $listen_port,
    open_listen_port       => $open_listen_port,
    database               => $database,
    database_port          => $database_port,
    database_username      => $database_username,
    database_password      => $database_password,
    database_name          => $database_name,
    dujour_package         => $dujour_package,
    dujour_version         => $dujour_version,
    dujour_service         => $dujour_service,
    manage_redhat_firewall => $manage_redhat_firewall,
    confdir                => $confdir,
    java_args              => $java_args,
  }

  if ($database == 'postgres') {
    class { 'dujour::database::postgresql':
      manage_redhat_firewall => $manage_redhat_firewall ? {
        true                 => $manage_redhat_firewall,
        false                => $manage_redhat_firewall,
        undef                => $open_postgres_port,
      },
      listen_addresses       => $dujour::params::postgres_listen_addresses,
      database_name          => $database_name,
      database_username      => $database_username,
      database_password      => $database_password,
      before                 => Class['dujour::server']
    }
  }
}
