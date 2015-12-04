class apache::ssl::redhat inherits apache::base::ssl {

  package {'mod_ssl':
    ensure => installed,
  }

  # we make sure it's empty to prevent it from being reinstalled with RPM upgrades
  file {'/etc/httpd/conf.d/ssl.conf':
    ensure  => present,
    content => "\n",
    require => Package['mod_ssl'],
    notify  => Service['apache'],
    before  => Exec['apache-graceful'],
  }

  apache::module { 'ssl':
    ensure    => present,
    template  => 'apache/ssl.load.rhel.erb',
    require   => File['/etc/httpd/conf.d/ssl.conf'],
    notify    => Service['apache'],
    before    => Exec['apache-graceful'],
  }
}
