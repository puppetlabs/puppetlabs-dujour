class dujour (
  database          = $database
  database_host     = $database_host
  database_port     = $database_port
  database_name     = $database_name
  database_username = $database_username
  database_password = $database_password
  dujour_version    = $dujour_version
  database_file     = $database_file
) inherits dujour::params {
  package { 'dujour':
    ensure => installed,
  }

  file {'/etc/dujour/config.clj':
    content  => template('dujour/config.clj.erb'),
    owner   => 'dujour',
    group   => 'dujour',
    notify  => Service['dujour'], # dujour will restart whenever you edit this file.
    require => Package['dujour'],
  }

  service { 'dujour':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    }}
