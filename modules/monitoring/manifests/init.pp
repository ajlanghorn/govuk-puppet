# == Class: monitoring
#
# Sets up monitoring.
#
class monitoring {

  package { 'python-rrdtool':
    ensure => 'installed',
  }

  include icinga
  include nsca::server

  include govuk::htpasswd

  # Monitoring server only.
  include monitoring::contacts
  include monitoring::checks
  include monitoring::edge
  include monitoring::event_handlers
  include monitoring::pagerduty_drill
  include monitoring::vpn_gateways

}
