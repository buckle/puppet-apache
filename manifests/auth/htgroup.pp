define apache::auth::htgroup (
  $groupname,
  $members,
  $ensure='present',
  $vhost=false,
  $groupFileLocation=false,
  $groupFileName='htgroup'){

  include apache::params

  if $groupFileLocation {
    $local_userFileLocation = $groupFileLocation
  } else {
    if $vhost {
      $local_userFileLocation = "${apache::params::root}/${vhost}/private"
    } else {
      fail 'parameter vhost is require !'
    }
  }

  $local_authGroupFile = "${$local_userFileLocation}/${groupFileName}"

  case $ensure {
    'present': {
      exec {"! test -f ${local_authGroupFile} && OPT='-c'; htgroup \$OPT ${local_authGroupFile} ${groupname} ${members}":
        unless  => "grep -qi '^${groupname}: ${members}$' ${local_authGroupFile}",
        require => File[$local_authGroupFile],
      }
    }
    'absent': {
      exec {"htgroup -D ${local_authGroupFile} ${groupname}":
        onlyif => "grep -q ${groupname} ${local_authGroupFile}",
        notify => Exec["delete ${local_authGroupFile} after remove ${groupname}"],
      }
      exec {"delete ${local_authGroupFile} after remove ${groupname}":
        command     => "rm -f ${local_authGroupFile}",
        onlyif      => "wc -l ${local_authGroupFile} | grep -q 0",
        refreshonly => true,
      }
    }
    default: {}
  }
}
