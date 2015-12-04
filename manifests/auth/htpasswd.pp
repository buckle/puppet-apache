define apache::auth::htpasswd (
  $username,
  $ensure='present',
  $vhost=false,
  $userFileLocation=false,
  $userFileName='htpasswd',
  $cryptPassword=false,
  $clearPassword=false){

  include apache::params

  if $userFileLocation {
    $local_userFileLocation = $userFileLocation
  } else {
    if $vhost {
      $local_userFileLocation = "${apache::params::root}/${vhost}/private"
    } else {
      fail 'parameter vhost is require !'
    }
  }

  $local_authUserFile = "${$local_userFileLocation}/${userFileName}"

  case $ensure {
    'present': {
      if $cryptPassword and $clearPassword {
        fail 'choose only one of cryptPassword OR clearPassword !'
      }
      if !$cryptPassword and !$clearPassword  {
        fail 'choose one of cryptPassword OR clearPassword !'
      }
      if $cryptPassword {
        exec {"! test -f ${local_authUserFile} && OPT='-c'; htpasswd -bp \$OPT ${local_authUserFile} ${username} '${cryptPassword}'":
          unless  => "grep -q ${username}:${cryptPassword} ${local_authUserFile}",
          require => File[$local_userFileLocation],
        }
      }
      if $clearPassword {
        exec {"! test -f ${local_authUserFile} && OPT='-c'; htpasswd -b \$OPT ${local_authUserFile} ${username} ${clearPassword}":
          unless  => "grep ${username} ${local_authUserFile} && grep ${username}:\$(mkpasswd -S \$(grep ${username} ${local_authUserFile} |cut -d : -f 2 |cut -c-2) ${clearPassword}) ${local_authUserFile}",
          require => File[$local_userFileLocation],
        }
      }
    }
    'absent': {
      exec {"htpasswd -D ${local_authUserFile} ${username}":
        onlyif => "grep -q ${username} ${local_authUserFile}",
        notify => Exec["delete ${local_authUserFile} after remove ${username}"],
      }
      exec {"delete ${local_authUserFile} after remove ${username}":
        command     => "rm -f ${local_authUserFile}",
        onlyif      => "wc -l ${local_authUserFile} | grep -q 0",
        refreshonly => true,
      }
    }
    default: {}
  }
}
