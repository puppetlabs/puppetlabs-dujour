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

  $config_dir = '/etc/puppetlabs/dujour'

  hocon_setting { 'global.logging-config':
    ensure  => present,
    path    => "${config_dir}/conf.d/dujour.conf",
    setting => 'global.logging-config',
    value   => "${config_dir}/logback.xml",
    require => Package['dujour'],
  }

  hocon_setting { 'webserver.host':
    ensure  => present,
    path    => "${config_dir}/conf.d/dujour.conf",
    setting => 'webserver.host',
    value   => $host,
    require => Package['dujour'],
  }

  hocon_setting { 'webserver.port':
    ensure  => present,
    path    => "${config_dir}/conf.d/dujour.conf",
    setting => 'webserver.port',
    value   => $port,
    require => Package['dujour'],
  }

  #hocon_setting { 'web-router-service':
  #  ensure  => present,
  #  path    => "${config_dir}/conf.d/dujour.conf",
  #  setting => 'web-router-service.dujour.core/dujour-service',
  #  value   => "",
  #  require => Package['dujour'],
  #}

  hocon_setting { 'database.classname':
    ensure  => present,
    path    => "${config_dir}/conf.d/dujour.conf",
    setting => 'database.classname',
    value   => 'org.postgresql.Driver',
    require => Package['dujour'],
  }

  hocon_setting { 'database.subprotocol':
    ensure  => present,
    path    => "${config_dir}/conf.d/dujour.conf",
    setting => 'database.subprotocol',
    value   => 'postgresql',
    require => Package['dujour'],
  }

  hocon_setting { 'database.username':
    ensure  => present,
    path    => "${config_dir}/conf.d/dujour.conf",
    setting => 'database.username',
    value   => $database_username,
    require => Package['dujour'],
  }

  hocon_setting { 'database.password':
    ensure  => present,
    path    => "${config_dir}/conf.d/dujour.conf",
    setting => 'database.password',
    value   => $database_password,
    require => Package['dujour'],
  }

  hocon_setting { 'database.subname':
    ensure  => present,
    path    => "${config_dir}/conf.d/dujour.conf",
    setting => 'database.subname',
    value   => "//${database_host}:${database_port}/${database_name}",
    require => Package['dujour'],
  }

  service { 'dujour':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
