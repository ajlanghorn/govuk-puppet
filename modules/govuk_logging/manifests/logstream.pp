# == Define: govuk_logging::logstream
#
# Creates an upstart job which tails a logfile and sends it to logship from tagalog.
#
# == Parameters
# [*logfile*]
#   Full path of the log to tail.
#
# [*tags*]
#   Optional array of strings to tag each request.
#
# [*fields*]
#   Optional hash of key=value pairs to add to each request.
#
# [*ensure*]
#   If set to absent any existing logstream jobs will be removed. Defaults to present.
#
# [*json*]
#   Whether the log is in json format. Defaults to false.
#
# [*statsd_metric*]
#   if defined, specifies statsd metric (in logship's CLI format) to
#   send to statsd. Defaults to undef.
#
define govuk_logging::logstream (
  $logfile,
  $ensure = present,
  $tags = [],
  $fields = {},
  $json = false,
  $statsd_metric = undef,
  $statsd_timers = []
) {

  validate_re($ensure, ['^present$','^absent$'])

  # added to whitelist in lib/puppet-lint/plugins/check_hiera.rb
  # this is necessary because it is a global override in a defined type
  $disable_logstreams = hiera('govuk_logging::logstream::disabled', false)
  validate_bool($disable_logstreams)

  $app_domain = hiera('app_domain')
  $upstart_name = regsubst($title, "\\.${app_domain}", '')

  if ($disable_logstreams) {
    # noop
  } elsif ($ensure == present) {
    file { "/etc/init/logstream-${upstart_name}.conf":
      ensure    => present,
      content   => template('govuk_logging/logstream.erb'),
      notify    => Service["logstream-${upstart_name}"],
      subscribe => Class['govuk_logging'],
    }

    service { "logstream-${upstart_name}":
      ensure    => running,
      provider  => 'upstart',
      subscribe => Class['govuk_logging'],
    }
  } else {
    file { "/etc/init/logstream-${upstart_name}.conf":
      ensure  => absent,
      require => Exec["logstream-STOP-${upstart_name}"],
    }

    exec { "logstream-STOP-${upstart_name}" :
      command => "initctl stop logstream-${upstart_name}",
      onlyif  => "initctl status logstream-${upstart_name}",
    }
  }

}
