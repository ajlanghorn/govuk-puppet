# == Class: monitoring::vpn_gateways
#
# Sets up vDC gateways as separate hosts so they can become parents of child
# hosts dependent on the state of their gateway.
#
# === Parameters:
#
#  [*endpoints*]
#    A hash of vDC gateways which contain the IP address to be created with
#    the icinga::host defined type
#
class monitoring::vpn_gateways (
  $endpoints = {}
) {
  validate_hash($endpoints)

  create_resources('icinga::host', $endpoints)


}
