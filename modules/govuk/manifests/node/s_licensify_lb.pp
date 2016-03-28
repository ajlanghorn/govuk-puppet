# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class govuk::node::s_licensify_lb (
  $licensify_frontend_servers,
  $licensify_backend_servers,
  $enable_feed_console = false,
){
  include govuk::node::s_base

  include loadbalancer

  loadbalancer::balance {
    # Licensify frontend
    'licensify':
      https_redirect => false,
      servers        => $licensify_frontend_servers,
      internal_only  => true;

    # Licensify upload pdf public endpoint
    'uploadlicence':
      internal_only => true,
      servers       => $licensify_frontend_servers;

    # Licensify admin interface
    'licensify-admin':
      internal_only => true,
      servers       => $licensify_backend_servers;

    # Licensing web forms
    'licensing-web-forms':
      https_redirect => true,
      servers        => $licensify_frontend_servers,
      internal_only  => true;

  }
  if ($enable_feed_console) {
    loadbalancer::balance {
      # Licensify feed frontend
      'licensify-feed':
        internal_only => true,
        servers       => $licensify_backend_servers;
    }
  }
}
