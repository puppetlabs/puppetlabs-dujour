# Class: dujour::database::postgresql
#
# This class manages a postgresql database instance suitable for use
# with dujour.  It uses the `puppetlabs/postgresql` puppet module
# for creating the dujour database instance and user account.
#
# This class is intended as a high-level abstraction to help simplify the process
# of getting your dujour postgres server up and running; for maximum
# configurability, you may choose not to use this class.  You may prefer to
# use `puppetlabs/postgresql` directly, use a different puppet postgres module,
# or manage your postgres setup on your own.  All of these approaches should
# be compatible with dujour.
#
# Parameters:
#   ['database_name']      - The name of the database instance to connect to.
#                            (defaults to `dujour`)
#   ['database_username']  - The name of the database user to connect as.
#                            (defaults to `dujour`)
#   ['database_password']  - The password for the database user.
#                            (defaults to `dujour`)
# Actions:
# - Creates and manages a database instance for use by dujour
#
# Requires:
# - `puppetlabs/postgresql`
#
class dujour::database::postgresql(
  $database_name          = $dujour::params::database_name,
  $database_username      = $dujour::params::database_username,
  $database_password      = $dujour::params::database_password,
) inherits dujour::params {

  # create the dujour database
  postgresql::db { $database_name:
    user     => $database_username,
    password => $database_password,
    grant    => 'all',
    require  => Class['postgresql::server'],
  }
}
