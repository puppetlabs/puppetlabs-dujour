# Class: dujour::database::postgresql_db
#
# This class manages a postgresql database instance suitable for use
# with dujour.  It uses the `puppetlabs/postgresql` puppet module for
# for creating the dujour database instance and user account.
#
# This class is included from the dujour::database::postgresql class
# but for maximum configurability, you may choose to use this class directly
# and set up the database server itself using `puppetlabs/postgresql` yourself.
#
# Parameters:
#   ['database_name']      - The name of the database instance to connect to.
#                            (defaults to `dujour`)
#   ['database_username']  - The name of the database user to connect as.
#                            (defaults to `dujour`)
#   ['database_password']  - The password for the database user.
#                            (defaults to `dujour`)
# Actions:
# - Creates and manages a postgres database instance for use by
#   dujour
#
# Requires:
# - `puppetlabs/postgresql`
#
# Sample Usage:
#   include dujour::database::postgresql_db
#
class dujour::database::postgresql_db(
  $database_name          = $dujour::params::database_name,
  $database_username      = $dujour::params::database_username,
  $database_password      = $dujour::params::database_password,
) inherits dujour::params {

  # create the dujour database
  postgresql::db{ $database_name:
    user     => $database_username,
    password => $database_password,
    grant    => 'all',
    require  => Class['::postgresql::server'],
  }
}
