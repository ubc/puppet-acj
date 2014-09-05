class acj::packages () {
  Exec {
    path => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
  }

  package { "zlib-devel":
    ensure => "installed"
  }
}
