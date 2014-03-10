class acj::packages () {
  Exec {
    path => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
  }

  package { "zlib-devel":
    ensure => "installed"
  }

  class {'python':
    version    => 'system',
    pip        => true,
    dev        => true,
    virtualenv => false,
    gunicorn   => false,
    uwsgi      => true,
  }

  python::pip { 'validictory':
    ensure => present,
  }

  python::pip { 'Flask-Principal':
    ensure => present,
  }

  /*python::pip { 'MySQL-python':
    ensure => present,
  }*/

  python::pip { 'Flask':
    ensure => present,
  }

  python::pip { 'Flask-SQLAlchemy':
    ensure => present,
  }

  python::pip { 'passlib':
    ensure => present,
  }

  python::pip { 'PIL':
    ensure => present,
  }

  python::pip { 'oauth':
    ensure => present,
  }

  python::pip { 'requests':
    ensure => present,
  }
  
  python::pip { 'alembic':
    ensure => present,
  }
  /*python::pip { 'google-api-python-client':
    ensure => present,
  }
  
  python::pip { 'Django':
    ensure => present,
  }

  python::pip { 'django-openid-auth':
    ensure => present,
  }*/

  class { 'mysql::bindings': 
    python_enable => true
  }
}
