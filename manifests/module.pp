define apache::module ($ensure='present') {

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
