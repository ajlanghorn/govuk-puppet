# == Class: govuk::apps:email_campaign_frontend
#
# Configure the email-campaign-frontend application
#
# === Parameters
#
# FIXME: Document all class parameters
#
# [*vhost*]
#   Virtual host used by the application.
#   Default: email-campaign-frontend
#
# [*nagios_memory_warning*]
#   Memory use at which Nagios should generate a warning.
#
# [*nagios_memory_critical*]
#   Memory use at which Nagios should generate a critical alert.
#
class govuk::apps::email_campaign_frontend(
  $vhost = 'email-campaign-frontend',
  $port = 3109,
  $enabled = true,
  $errbit_api_key = undef,
  $secret_key_base = undef,
  $publishing_api_bearer_token = undef,
  $nagios_memory_warning = undef,
  $nagios_memory_critical = undef,
) {
  $app_name = 'email-campaign-frontend'

  if $enabled {
    govuk::app { $app_name:
      app_type               => 'rack',
      port                   => $port,
      health_check_path      => '/healthcheck',
      log_format_is_json     => true,
      asset_pipeline         => true,
      asset_pipeline_prefix  => 'email-campaign-frontend',
      nagios_memory_warning  => $nagios_memory_warning,
      nagios_memory_critical => $nagios_memory_critical,
      vhost                  => $vhost,
    }

    Govuk::App::Envvar {
      app => $app_name,
    }

    govuk::app::envvar { "${title}-PUBLISHING_API_BEARER_TOKEN":
      varname => 'PUBLISHING_API_BEARER_TOKEN',
      value   => $publishing_api_bearer_token,
    }

    if $errbit_api_key != undef {
      govuk::app::envvar {
        "${title}-ERRBIT_API_KEY":
          varname => 'ERRBIT_API_KEY',
          value   => $errbit_api_key;
      }
    }

    if $secret_key_base != undef {
      govuk::app::envvar { "${title}-SECRET_KEY_BASE":
        varname => 'SECRET_KEY_BASE',
        value   => $secret_key_base,
      }
    }
  }
}
