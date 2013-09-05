class dujour (
  $host              = $dujour::params::host,
  $port              = $dujour::params::port,
  $database          = $dujour::params::database,
  $database_host     = $dujour::params::database_host,
  $database_port     = $dujour::params::database_port,
  $database_name     = $dujour::params::database_name,
  $database_username = $dujour::params::database_username,
  $database_password = $dujour::params::database_password,
  $version           = $dujour::params::version,
  $database_file     = $dujour::params::database_file,
) inherits dujour::params {
  package { 'dujour':
    ensure => $version,
  }

  file {'/etc/dujour/config.clj':
    content => template('dujour/config.clj.erb'),
    owner   => 'dujour',
    group   => 'dujour',
    mode    => 640,
    notify  => Service['dujour'], # dujour will restart whenever you edit this file.
    require => Package['dujour'],
  }

  service { 'dujour':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    }}
