# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class licensify::apps::licensing_web_forms( $port = 9450, $enabled = false ) inherits licensify::apps::base {
  if $enabled {
    govuk::app { 'licensing-web-forms':
      ensure            => absent,
      app_type          => 'procfile',
      port              => $port,
      health_check_path => '/',
    }
  }
}
