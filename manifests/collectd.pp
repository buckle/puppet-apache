/*
== Class: apache::collectd

Configures collectd's apache plugin. This gathers data from apache's
server-status and stores it in rrd files, from which you can make nice
graphs.

You will need collectd up and running, which can be cone using the
puppet-collectd module.

Requires:
- Class["collectd"]

Usage:
  include apache
  include collectd
  include apache::collectd

*/
class apache::collectd {

  if ($::operatingsystem == 'RedHat' or $::operatingsystem == 'CentOS') {
    package { 'collectd-apache':
      ensure => present,
      notify => Service['collectd'],
    }
  }

  $content = 'LoadPlugin apache
<Plugin apache>
       URL "http://localhost/server.status?auto"
</Plugin>'

  collectd::plugin { 'apache':
    ensure  => 'present',
    content => $content,
  }

}
