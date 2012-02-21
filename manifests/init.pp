/*

== Class: apache

Installs apache, ensures a few useful modules are installed (see apache::base),
ensures that the service is running and the logs get rotated.

By including subclasses where distro specific stuff is handled, it ensure that
the apache class behaves the same way on diffrent distributions.

Example usage:

  include apache

*/
class apache(
  $start_servers = 8,
  $min_spare_servers = 5,
  $max_spare_servers = 20,
  $server_limit = 256,
  $max_clients = 256,
  $max_requests_per_child = 4000,
  ) {

  include apache::params, bke_firewall::http_server
  case $operatingsystem {
    Debian,Ubuntu:  { $classname = 'apache::debian' }
    RedHat,CentOS:  { $classname = 'apache::redhat' }
    default: { notice "Unsupported operatingsystem ${operatingsystem}" }
  }
  class{ $classname:
    start_servers          => $start_servers,
    min_spare_servers      => $min_spare_servers,
    max_spare_servers      => $max_spare_servers,
    server_limit           => $server_limit,
    max_clients            => $max_clients,
    max_requests_per_child => $max_requests_per_child,
  }
}
