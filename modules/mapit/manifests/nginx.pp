# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class mapit::nginx {
  include ::nginx

  nginx::config::ssl { 'wildcard_alphagov':
    certtype => 'wildcard_alphagov',
  }

  nginx::config::site { 'mapit':
    source  => 'puppet:///modules/mapit/nginx_mapit.conf',
  }

  nginx::log {
    'mapit.json.event.access.log':
      json          => true,
      logstream     => present,
      statsd_metric => "${::fqdn_metrics}.nginx_logs.mapit.http_%{@fields.status}",
      statsd_timers => [{metric => "${::fqdn_metrics}.nginx_logs.mapit.time_request",
                          value => '@fields.request_time'}];
    'mapit.error.log':
      logstream => present;
  }
}
