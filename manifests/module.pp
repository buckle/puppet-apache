define apache::module ($ensure='present',$template = undef) {

  include apache::params

  $a2enmod_deps = $operatingsystem ? {
    /RedHat|CentOS/ => [
      Package["apache"],
      File["/etc/httpd/mods-available"],
      File["/etc/httpd/mods-enabled"],
      File["${apache::params::a2scripts_dir}/a2enmod"],
      File["${apache::params::a2scripts_dir}/a2dismod"]
    ],
    /Debian|Ubuntu/ => Package["apache"],
  }

  if $selinux == "true" {
    apache::redhat::selinux {$name: }
  }

  if $operatingsystem == "CentOS" or $operatingsystem == "RedHat" {
    file { "${apache::params::conf_dir}/mods-available/${name}.load":
      ensure => present,
      mode => 644,
      owner => "root",
      group => "root",
      seltype => "httpd_config_t",
      require => Package["apache"],
      content => $template ? {
        undef => inline_template("LoadModule ${name}_module modules/mod_${name}.so\n"),
        default => template("$template"),
      },
    }
  }

  case $ensure {
    'present', 'enabled' : {
      exec { "a2enmod ${name}":
        command => "${apache::params::a2scripts_dir}/a2enmod ${name}",
        unless  => "/bin/sh -c '[ -L ${apache::params::conf_dir}/mods-enabled/${name}.load ] \\
          && [ ${apache::params::conf_dir}/mods-enabled/${name}.load -ef ${apache::params::conf_dir}/mods-available/${name}.load ]'",
        require => $a2enmod_deps,
        notify  => Exec["apache-graceful"],
      }
    }

    'absent', 'disabled' : {
      exec { "a2dismod ${name}":
        command => "${apache::params::a2scripts_dir}/a2dismod ${name}",
        onlyif  => "/bin/sh -c '[ -L ${apache::params::conf_dir}/mods-enabled/${name}.load ] \\
          || [ -e ${apache::params::conf_dir}/mods-enabled/${name}.load ]'",
        require => $a2enmod_deps,
        notify  => Exec["apache-graceful"],
       }
    }

    default: { 
      err ( "Unknown ensure value: '${ensure}'" ) 
    }
  }
}
