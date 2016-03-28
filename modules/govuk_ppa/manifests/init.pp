# == Class: govuk_ppa
#
# === Parameters
#
# [*apt_mirror_hostname*]
#   Hostname to use for the APT mirror when setting up our PPA.
#   Defaults to undefined because `$use_mirror` can be disabled.
#
# [*path*]
#   Path that constitutes the last part of the repository. This can be used
#   to present a different snapshot to an environment, e.g. `integration`
#   Default: `production`
#
# [*use_mirror*]
#   Whether to use our snapshotted mirror of the PPA. Things may break if
#   you disable this, because package versions may have changed and PPAs
#   only allow you to access the latest version.
#   Default: true
#
class govuk_ppa (
  $apt_mirror_hostname = undef,
  $path = 'production',
  $use_mirror = true,
) {
  validate_bool($use_mirror)
  if $use_mirror {
    apt::source { 'govuk-ppa':
      location     => "http://${apt_mirror_hostname}/govuk/ppa/${path}",
      architecture => $::architecture,
      key          => '3803E444EB0235822AA36A66EC5FE1A937E3ACBB',
    }
  } else {
    apt::ppa { 'ppa:gds/govuk': }
  }
}
