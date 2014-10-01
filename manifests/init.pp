# installation note

class acj (
  $docroot = '/www_data/acj',
  $timezone = 'US/Pacific',
  $ensure = 'present',
  $host     = $fqdn,
  $port    = 80,
  $db_host = 'localhost',
  $db_user = 'acj',
  $db_password = 'acjsecret',
  $db_name = 'acj',
  $ssl = false,
  $ssl_cert = undef,
  $ssl_key = undef,
  $ssl_port = 443,
) {

  class { 'selinux':
    mode => 'disabled'
  }
  
  include git

  class {'python':
    version    => 'system',
    pip        => true,
    dev        => true,
    virtualenv => false,
    gunicorn   => false,
    uwsgi      => true,
    uwsgi_cfg  => {
      'env' => "DATABASE_URI = mysql+pymysql://${db_user}:${db_password}@${db_host}/${db_name}",
    }
  }

  include acj::packages

  firewall { "100 allow http and https access":
    port   => [80, 443],
    proto  => tcp,
    action => accept,
  }

  class { 'nginx': 
    client_max_body_size => '30m', # instructor wants larger pdf uploads
  }

  if $ssl {
    nginx::resource::vhost { "redirect_$host":
      ensure              => present,
      server_name         => [$host],
      www_root            => $docroot,
      location_cfg_append => { 'rewrite' => '^ https://$server_name$request_uri? permanent' },
    }
  }

  nginx::resource::vhost { "$host":
    client_max_body_size => '30m', # instructor wants larger pdf uploads
    ensure => present,
    listen_port => $port,
    ssl => $ssl,
    ssl_cert => $ssl_cert,
    ssl_key  => $ssl_key,
    ssl_port => $ssl_port,
    location_custom_cfg => {
	try_files => '$uri @acj',
    }
  }

  nginx::resource::location { 'acj':
    vhost => $host, 
    ssl_only => true,
    location => '@acj',
    location_custom_cfg => {
	include => 'uwsgi_params',
  	uwsgi_pass => 'unix:/tmp/uwsgi.sock'
    }
  }

  nginx::resource::location { 'static':
    vhost => $host, 
    ssl_only => $ssl,
    location => '/static',
    location_alias => '/www_data/acj/acj/static',
  }

  class { '::mysql::server':
    root_password => '99bobotw', 
    restart => true,
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

