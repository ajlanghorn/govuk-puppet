class development {
  include base

  include apollo
  include base_packages
  include elasticsearch
  include hosts
  include imagemagick
  include mongodb::server
  include mysql::client
  include nodejs
  include puppet
  include solr
  include tmpreaper
  include users
  include clamav

  include govuk::apps::review_o_matic_explore
  include govuk::apps::planner
  include govuk::apps::tariff
  include govuk::apps::feedback
  include govuk::apps::contentapi
  include govuk::apps::publicapi

  include govuk::deploy
  include govuk::repository
  include govuk::testing_tools

  elasticsearch::node { 'govuk-development':
    heap_size          => '64m',
    number_of_shards   => '1',
    number_of_replicas => '0',
  }

  include nginx

  nginx::config::site { '/etc/nginx/sites-enabled/default':
    # FIXME: this file probably shouldn't live in the nginx module,
    # can't think of a better place at the moment
    source  => 'puppet:///modules/nginx/development',
  }

  $mysql_password = ''
  class { 'mysql::server':
    root_password => $mysql_password
  }

  mysql::server::db {
    'fco_development':                user => 'fco',          password => '',             host => 'localhost', root_password => $mysql_password, remote_host => 'localhost';
    'needotron_development':          user => 'needotron',    password => '',             host => 'localhost', root_password => $mysql_password, remote_host => 'localhost';
    'panopticon_development':         user => 'panopticon',   password => 'panopticon',   host => 'localhost', root_password => $mysql_password, remote_host => 'localhost';
    'panopticon_test':                user => 'panopticon',   password => 'panopticon',   host => 'localhost', root_password => $mysql_password, remote_host => 'localhost';
    'contactotron_development':       user => 'contactotron', password => 'contactotron', host => 'localhost', root_password => $mysql_password, remote_host => 'localhost';
    'contactotron_test':              user => 'contactotron', password => 'contactotron', host => 'localhost', root_password => $mysql_password, remote_host => 'localhost';
    'signonotron2_development':       user => 'signonotron2', password => '',             host => 'localhost', root_password => $mysql_password, remote_host => 'localhost';
    'signonotron2_test':              user => 'signonotron2', password => '',             host => 'localhost', root_password => $mysql_password, remote_host => 'localhost';
    'signonotron2_integration_test':  user => 'signonotron2', password => '',             host => 'localhost', root_password => $mysql_password, remote_host => 'localhost';
    'whitehall_development':          user => 'whitehall',    password => 'whitehall',    host => 'localhost', root_password => $mysql_password, remote_host => 'localhost';
    'whitehall_test':                 user => 'whitehall',    password => 'whitehall',    host => 'localhost', root_password => $mysql_password, remote_host => 'localhost';
    'efg_development':                user => 'efg',          password => 'efg',          host => 'localhost', root_password => $mysql_password, remote_host => 'localhost';
    'efg_test':                       user => 'efg',          password => 'efg',          host => 'localhost', root_password => $mysql_password, remote_host => 'localhost';
    'tariff_development':             user => 'tariff',       password => 'tariff',       host => 'localhost', root_password => $mysql_password, remote_host => 'localhost';
    'tariff_test':                    user => 'tariff',       password => 'tariff',       host => 'localhost', root_password => $mysql_password, remote_host => 'localhost';
  }

  package {
    'foreman':        ensure => '0.27.0',    provider => gem;
    'linecache19':    ensure => 'installed', provider => gem;
    'mysql2':         ensure => 'installed', provider => gem, require => Class['mysql::client'];
    'rails':          ensure => 'installed', provider => gem;
    'passenger':      ensure => 'installed', provider => gem;
    'wbritish-small': ensure => installed;
  }
}
