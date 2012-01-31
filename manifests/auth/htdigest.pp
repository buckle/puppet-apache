define apache::auth::htdigest (
  $ensure="present",
  $vhost=false,
  $userFileLocation=false,
  $userFileName=".htdigest_pw",
  $username,
  $realm=false,
  $cryptPassword=false,
  $clearPassword=false){

  include apache::params
  include concat::setup

  if $userFileLocation {
    $_userFileLocation = $userFileLocation
  } else {
    if $vhost {
      $_userFileLocation = "${apache::params::root}/${vhost}/private"
    } else {
      fail "parameter vhost is required!"
    }
  }

  if ! $realm {
    if $vhost {
      $realm = $vhost
    }
    else {
      $realm = "Private Area"
    }
  }

  $_authUserFile = "${_userFileLocation}/${userFileName}"

  case $ensure {

    'present': {
      if $cryptPassword and $clearPassword {
        fail "choose only one of cryptPassword OR clearPassword !"
      }

      if !$cryptPassword and !$clearPassword  {
        fail "choose one of cryptPassword OR clearPassword !"
      }

      if $clearPassword {
        $cryptPassword = md5("${username}:${realm}:${clearPassword}")
      }

      concat::fragment{ "${_userFile}_${username}_${realm}":
        target  => $_authUserFile,
        content => "${username}:${ream}:${cryptPassword}\n",
      }
    }
  }
}
