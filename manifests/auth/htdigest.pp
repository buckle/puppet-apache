define apache::auth::htdigest (
  $username,
  $ensure='present',
  $vhost=false,
  $userFileLocation=false,
  $userFileName='.htdigest_pw',
  $realm=false,
  $cryptPassword=false,
  $clearPassword=false
){

  include apache::params
  include concat::setup

  if $userFileLocation {
    $local_userFileLocation = $userFileLocation
  } else {
    if $vhost {
      $local_userFileLocation = "${apache::params::root}/${vhost}/private"
    } else {
      fail 'parameter vhost is required!'
    }
  }

  if ! $realm {
    if $vhost {
      $realm = $vhost
    }
    else {
      $realm = 'Private Area'
    }
  }

  $local_authUserFile = "${$local_userFileLocation}/${userFileName}"

  if ($ensure == 'present') {
    if $cryptPassword and $clearPassword {
      fail 'choose only one of cryptPassword OR clearPassword !'
    }
    if !$cryptPassword and !$clearPassword  {
      fail 'choose one of cryptPassword OR clearPassword !'
    }
    if $clearPassword {
      $password = md5("${username}:${realm}:${clearPassword}")
    }
    else {
      $password = $cryptPassword
    }
    concat::fragment{ "${name} - ${userFileName}_${username}_${realm}":
      target  => $local_authUserFile,
      content => "${username}:${realm}:${password}\n",
    }
  }
}
