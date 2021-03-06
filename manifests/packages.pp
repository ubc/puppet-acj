class acj::packages () {
  Exec {
    path => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
  }

  package { "libffi-devel":
    ensure => "installed"
  }

  package { "zlib-devel":
    ensure => "installed"
  }

  package { "nodejs":
    ensure => "installed"
  }

  package { "npm":
    ensure => "installed"
  }
}
