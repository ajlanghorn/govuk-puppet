# == Class: govuk::apps::rummager::rabbitmq
#
# Permissions for rummager to read messages from
# the publishing API's AMQP exchange.
#
# This sets up the user, and permits read/write/configure
# to the queue, and read-only to the exchange.
#
# === Parameters
#
# [*password*]
#   The password for the RabbitMQ user (default: 'rummager')
#
class govuk::apps::rummager::rabbitmq (
  $password  = 'rummager',
) {

  govuk_rabbitmq::consumer { 'rummager':
    amqp_pass     => $password,
    amqp_exchange => 'published_documents',
    amqp_queue    => 'rummager_to_be_indexed',
  }
}
