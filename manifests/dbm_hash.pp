define apache::dbm_hash(
  $destination,
  $template = undef
) {
  $erb_path = $template ? {
    undef   => $name,
    default => $template,
  }
  $mapfile = regsubst($destination, '(.*)\.(.*)$', '\1.map')

  file { $destination:
    ensure  => present,
    notify  => Exec["httxt2dbm ${mapfile}"],
    content => template($erb_path),
  }
  exec { "httxt2dbm ${mapfile}":
    refreshonly => true,
    command     => "/usr/sbin/httxt2dbm -i ${destination} -o ${mapfile}",
    notify      => Exec['apache-graceful'],
  }
}
