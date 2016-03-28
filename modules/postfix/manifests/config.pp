# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class postfix::config(
  $smarthost,
  $smarthost_user,
  $smarthost_pass,
  $rewrite_mail_domain,
  $rewrite_mail_list
) {

  file { '/etc/mailname':
    ensure  => present,
    content => "${::fqdn}\n",
  }

  file { '/etc/postfix/main.cf':
    content => template('postfix/etc/postfix/main.cf.erb'),
    notify  => Service[postfix],
    require => File['/etc/mailname'],
  }

  if $smarthost {

    postfix::postmapfile { 'outbound_rewrites':     named => 'outbound_rewrites' }
    postfix::postmapfile { 'local_remote_rewrites': named => 'local_remote_rewrites' }

    if ($smarthost_user and $smarthost_pass) {
      postfix::postmapfile { 'sasl_passwd': named => 'sasl_passwd' }
    }
  }

}
