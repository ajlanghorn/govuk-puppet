# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class icinga::service {

  service { 'icinga':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
  }

}
