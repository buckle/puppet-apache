/*
== Definition: apache::listen

Adds a "Listen" directive to apache's ports.conf file.

Parameters:
- *ensure*: present/absent.
- *name*: port number, or ipaddress:port

Requires:
- Class["apache"]

Example usage:

  apache::listen { "80": }
  apache::listen { "127.0.0.1:8080": ensure => present }

*/
define apache::listen (
  $ensure='present'
) {

  include apache::params

  concat::fragment { "apache-ports.conf-fragment-${name}":
    target  => "${apache::params::conf_dir}/ports.conf",
    content => "Listen ${name}\n",
    require => Package['apache'],
    notify  => Service['apache'],
  }

}
