# == Class: govuk::apps::imminence
#
# Imminence manages sets of (somewhat) structured data for use
# elsewhere on GOV.UK. It's primarily used for geographical data such
# as lists of registry offices, test centres, and the like. There is a
# simple JSON API for integrating the data with other applications.
#
# === Parameters
#
# [*port*]
#   The port that Imminence is served on.
#   Default: 3002
#
# [*enable_procfile_worker*]
#   Whether to enable the Procfile worker.
#
# [*mongodb_nodes*]
#   An array of MongoDB instance hostnames
#
# [*mongodb_name*]
#   The name of the MongoDB database to use
#
# [*secret_key_base*]
#   The key for Rails to use when signing/encrypting sessions.
#
# [*nagios_memory_warning*]
#   Memory use at which Nagios should generate a warning.
#
# [*nagios_memory_critical*]
#   Memory use at which Nagios should generate a critical alert.
#
class govuk::apps::imminence(
  $port = '3002',
  $enable_procfile_worker = true,
  $mongodb_nodes = undef,
  $mongodb_name = 'imminence_production',
  $secret_key_base = undef,
  $nagios_memory_warning = undef,
  $nagios_memory_critical = undef,
) {

  $app_name = 'imminence'

  Govuk::App::Envvar {
    app => $app_name,
  }

  govuk::app { $app_name:
    app_type               => 'rack',
    port                   => $port,
    vhost_ssl_only         => true,
    health_check_path      => '/',
    log_format_is_json     => true,
    asset_pipeline         => true,
    nagios_memory_warning  => $nagios_memory_warning,
    nagios_memory_critical => $nagios_memory_critical,
  }

  if $secret_key_base {
    govuk::app::envvar {
      "${title}-SECRET_KEY_BASE":
      varname => 'SECRET_KEY_BASE',
      value   => $secret_key_base;
    }
  }

  if $::govuk_node_class != 'development' {
    govuk::app::envvar::mongodb_uri { $app_name:
      hosts    => $mongodb_nodes,
      database => $mongodb_name,
    }
  }

  govuk::procfile::worker { $app_name:
    enable_service => $enable_procfile_worker,
  }
}
