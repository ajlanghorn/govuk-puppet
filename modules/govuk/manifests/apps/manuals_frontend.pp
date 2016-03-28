# == Class: govuk::apps::manuals_frontend
#
# Front-end app for the manuals format.
#
# === Parameters
#
# [*vhost*]
#   Virtual host used by the application.
#   Default: 'manuals-frontend'
#
# [*port*]
#   The port that the app is served on.
#   Default: 3072
#
# [*publishing_api_bearer_token*]
#   The bearer token to use when communicating with Publishing API.
#   Default: undef
#
class govuk::apps::manuals_frontend(
  $vhost = 'manuals-frontend',
  $port = '3072',
  $publishing_api_bearer_token = undef,
) {
  govuk::app { 'manuals-frontend':
    app_type              => 'rack',
    port                  => $port,
    asset_pipeline        => true,
    asset_pipeline_prefix => 'manuals-frontend',
    vhost                 => $vhost,
  }

  govuk::app::envvar { "${title}-PUBLISHING_API_BEARER_TOKEN":
    app     => 'manuals-frontend',
    varname => 'PUBLISHING_API_BEARER_TOKEN',
    value   => $publishing_api_bearer_token,
  }
}
