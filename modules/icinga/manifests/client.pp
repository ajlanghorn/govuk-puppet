# == Class: icinga::client
#
# Sets up a host in Icinga that checks can be associated with.
#
class icinga::client {

  anchor { 'icinga::client::begin':
    before => Class['icinga::client::package'],
    notify => Class['icinga::client::service'],
  }

  class { 'icinga::client::package':
    notify => Class['icinga::client::service'],
  }

  class { 'icinga::client::config':
    require => Class['icinga::client::package'],
    notify  => Class['icinga::client::service'],
  }

  class { 'icinga::client::checks':
    require => Class['icinga::client::config'],
    notify  => Class['icinga::client::service'],
  }

  class { 'icinga::client::firewall':
    require => Class['icinga::client::config'],
  }

  class { 'icinga::client::service': }

  anchor { 'icinga::client::end':
    require => Class[
      'icinga::client::firewall',
      'icinga::client::service'
    ],
  }

  @@icinga::host { $::fqdn:
    hostalias    => $::fqdn,
    address      => $::ipaddress,
    display_name => $::fqdn_short,
  }

  Icinga::Nrpe_config <| |>
  Icinga::Plugin <| |>
  Icinga::Plugin <<| |>>
}
