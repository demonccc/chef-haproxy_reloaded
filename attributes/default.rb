# Daemon options

default['haproxy']['daemon']['enable'] = true
default['haproxy']['daemon']['extra_options'] = false
#default['haproxy']['daemon']['extra_options'] = "-de -m 16"

# Global section

default['haproxy']['global'] = {
  'log' => {
    '/dev/log' => [ 'local0' ]
  },
  'maxconn' => 4096,
  'daemon' => true,
  'debug' => false,
  'quiet' => false,
  'user' => 'haproxy',
  'group' => 'haproxy'
}

# Default section

default['haproxy']['defaults'] = {
  'log' => 'global',
  'mode' => 'http',
  'option' => [ 'httplog', 'dontlognull', 'redispatch' ],
  'retries' =>  3,
  'maxconn' => 2000,
  'timeout' => {
    'connect' => 50000,
    'client' => 50000, 
    'server' => 50000
  }
}

# Frontends

default['haproxy']['frontend'] = {}
#default['haproxy']['frontend'] = {
#  'http-www' => {
#    'bind' => '*:80',
#    'option' => [ 'forwardfor' ],
#    'default_backend' => 'webservers'
#  }
#}

# Backends

default['haproxy']['backend'] = {}
#default['haproxy']['backend'] = {
#  'webservers' => {
#    'balance' => 'roundrobin',
#    'option' => [ 'httpclose'],
#    'timeout' => {
#      'check' => '5s'
#    },
#    'member_options' => {
#      'search' => 'role:webserver',
#      'search_extra_environments' => [
#        'another-environment-name'
#      ],
#      'port' => "80",
#      'options' => "cookie #{server['hostname']} check port 80"
#    }
#  }
#}

# Listens

default['haproxy']['listen'] = {}
#default['haproxy']['listen'] = {
#  'stats' => {
#    'stats": {
#      'uri' => '/stats',
#      'realm' => 'HAProxy\\ Statistics',
#      'auth' => 'admin:admin',
#      'admin' => 'if TRUE'
#    }
#  },
#  'health' => {
#    'bind' => '127.0.0.1:6000',
#    'mode' => 'health',
#    'option' => [ 'tcplog' ]
#  }
#}
