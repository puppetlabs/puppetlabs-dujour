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
  $listen_address            = 'localhost'
  $listen_port               = '8080'
  $open_listen_port          = false
  $postgres_listen_addresses = 'localhost'
  # This technically defaults to 'true', but in order to preserve backwards
  # compatibility with the deprecated 'manage_redhat_firewall' parameter, we
  # need to specify 'undef' as the default so that we can tell whether or
  # not the user explicitly specified a value.  See implementation in
  # `postgresql.pp`.  We should change this back to `true` when we get rid
  # of `manage_redhat_firewall`.
  $open_postgres_port        = undef

  $database                  = 'postgres'

  # The remaining database settings are not used for an embedded database
  $database_host          = 'localhost'
  $database_port          = '5432'
  $database_name          = 'dujour'
  $database_username      = 'dujour'
  $database_password      = 'dujour'

  $dujour_version       = 'present'

  # TODO: figure out a way to make this not platform-specific
  $manage_redhat_firewall = undef

  $gc_interval            = '60'

  case $::osfamily {
    'RedHat': {
      $firewall_supported       = true
      $persist_firewall_command = '/sbin/iptables-save > /etc/sysconfig/iptables'
    }

    'Debian': {
      $firewall_supported       = false
      # TODO: not exactly sure yet what the right thing to do for Debian/Ubuntu is.
      #$persist_firewall_command = '/sbin/iptables-save > /etc/iptables/rules.v4'
    }
    default: {
      $firewall_supported       = false
    }
  }

  $dujour_package     = 'dujour'
  $dujour_service     = 'dujour'
  $confdir              = '/etc/dujour/conf.d'
  $puppet_service_name  = 'puppetmaster'
  $puppet_confdir       = '/etc/puppet'
  $embedded_subname     = 'file:/usr/share/dujour/db/db;hsqldb.tx=mvcc;sql.syntax_pgs=true'

  case $::osfamily {
    'RedHat' : {
      $dujour_initconf = '/etc/sysconfig/dujour'
    }
    'Debian': {
      $dujour_initconf = '/etc/default/dujour'
    }
    default: {
      fail("${module_name} supports osfamily's RedHat and Debian. Your osfamily is recognized as ${::osfamily}")
    }
  }

  $puppet_conf              = "${puppet_confdir}/puppet.conf"
  $dujour_startup_timeout = 120
}
