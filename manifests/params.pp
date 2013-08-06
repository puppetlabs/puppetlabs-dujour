# Class: dujour::params
#
#   The dujour configuration settings.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class dujour::params {
  $database             = 'hsqldb'
  $database_host        = 'localhost'
  $database_port        = '5432'
  $database_name        = 'dujour'
  $database_username    = 'dujour'
  $database_password    = 'dujour'
  $dujour_package       = 'dujour'
  $version              = 'present'
  $dujour_service       = 'dujour'
  $database_file        = '/usr/share/dujour/db/db' #file:   ...   ;hsqldb.tx=mvcc;sql.syntax_pgs=true'
}
