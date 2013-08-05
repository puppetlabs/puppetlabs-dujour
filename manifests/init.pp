package { 'dujour':
  ensure => installed,
}

file {'/etc/dujour/config.clj':
  source  => 'puppet:///modules/dujour/config.clj',
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
}
