# installation note

class acj (
  $docroot = '/www_data/acj',
  $timezone = 'US/Pacific',
  $ensure = 'present',
  $host     = $fqdn,
  $db_host = 'localhost',
  $db_user = 'acj',
  $db_password = 'acjsecret',
  $db_name = 'acj',
) {

  class { 'selinux':
    mode => 'disabled'
  }
  
  include git

  include acj::packages

  firewall { '100 allow http access':
    port   => [80],
    proto  => tcp,
    action => accept,
  }

  class { 'nginx': }

  nginx::resource::vhost { "$host":
    ensure => present,
    location_custom_cfg => {
	try_files => '$uri @acj',
    }
  }

  nginx::resource::location { 'acj':
    vhost => $host, 
    location => '@acj',
    location_custom_cfg => {
	include => 'uwsgi_params',
  	uwsgi_pass => 'unix:/tmp/uwsgi.sock'
    }
  }

  nginx::resource::location { 'static':
    vhost => $host, 
    location => '/static',
    location_alias => '/www_data/acj/acj/static',
  }

  class { '::mysql::server':
    root_password => '99bobotw', 
    override_options => {
      'mysqld' => {
    	'bind_address' => '0.0.0.0',
      }
    }
  }

  mysql::db { $db_name:
    user     => $db_user,
    password => $db_password,
    host     => $db_host,
    grant    => ['all'],
  }
}

