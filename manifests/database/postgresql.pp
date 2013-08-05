# Class: dujour::database::postgresql
#
# This class manages a postgresql server and database instance suitable for use
# with dujour.  It uses the `puppetlabs/postgresql` puppet module for getting
# the postgres server up and running, and then also for creating the dujour
# database instance and user account.
#
# This class is intended as a high-level abstraction to help simplify the process
# of getting your dujour postgres server up and running; for maximum
# configurability, you may choose not to use this class.  You may prefer to
# use `puppetlabs/postgresql` directly, use a different puppet postgres module,
# or manage your postgres setup on your own.  All of these approaches should
# be compatible with dujour.
#
# Parameters:
#   ['listen_addresses']   - A comma-separated list of hostnames or IP addresses
#                            on which the postgres server should listen for incoming
#                            connections.  (Defaults to 'localhost'.  This parameter
#                            maps directly to postgresql's 'listen_addresses' config
#                            option; use a '*' to allow connections on any accessible
#                            address.
#   ['database_name']      - The name of the database instance to connect to.
#                            (defaults to `dujour`)
#   ['database_username']  - The name of the database user to connect as.
#                            (defaults to `dujour`)
#   ['database_password']  - The password for the database user.
#                            (defaults to `dujour`)
# Actions:
# - Creates and manages a postgres server and database instance for use by
#   dujour
#
# Requires:
# - `puppetlabs/postgresql`
#
# Sample Usage:
#   class { 'dujour::database::postgresql':
#       listen_addresses         => 'my.postgres.host.name',
#   }
#
class dujour::database::postgresql(
  # TODO: expose more of the parameters from `puppetlabs/postgresql`!
  $listen_addresses       = $dujour::params::database_host,
  $manage_redhat_firewall = $dujour::params::open_postgres_port,
  $database_name          = $dujour::params::database_name,
  $database_username      = $dujour::params::database_username,
  $database_password      = $dujour::params::database_password,
) inherits dujour::params {

  # This technically defaults to 'true', but in order to preserve backwards
  # compatibility with the deprecated 'manage_redhat_firewall' parameter, we
  # had to specify 'undef' as the default so that we could tell whether or
  # not the user explicitly specified a value. Here's where we're resolving
  # that and setting the 'real' default.  We should be able to get rid of
  # this block when we remove `manage_redhat_firewall`.
  if ($manage_redhat_firewall != undef) {
    $final_manage_redhat_firewall = $manage_redhat_firewall
  } else {
    $final_manage_redhat_firewall = true
  }


  # get the pg server up and running
  class { '::postgresql::server':
    config_hash => {
      # TODO: make this stuff configurable
      'ip_mask_allow_all_users' => '0.0.0.0/0',
      'listen_addresses'        => $listen_addresses,
      'manage_redhat_firewall'  => $final_manage_redhat_firewall,
    },
  }

  # create the dujour database
  class { 'dujour::database::postgresql_db':
    database_name     => $database_name,
    database_username => $database_username,
    database_password => $database_password,
  }
}
