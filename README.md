# haproxy_reloaded Cookbook

## Description

This cookbook installs, configures and manages Haproxy.

## Requirements

### Chef
Tested on 11.12.8 but newer and older version should work just fine.

### Platform
The following platforms have been tested with this cookbook, meaning that the recipes run on these platforms without error:
- `Ubuntu`
- `Debian`

### Cookbooks

There are **no** external cookbook dependencies.

## Capabilities

## Attributes

### haproxy_reloaded::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['haproxy']['daemon']['enable']</tt></td>
    <td>Boolean</td>
    <td>Enable or disable Haproxy</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['haproxy']['daemon']['extra_options']</tt></td>
    <td>String</td>
    <td>Daemon extra options. If you don't need extra options, set it to boolean false</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['haproxy']['global']</tt></td>
    <td>Hash</td>
    <td>Haproxy global parameters</td>
    <td><tt>{ 'log' => { /dev/log' => [ 'local0' ] }, 'maxconn' => 4096, 'daemon' => true, 'debug' => false, 'quiet' => false, 'user' => 'haproxy', 'group' => 'haproxy' }</tt></td>
  </tr>
  <tr>
    <td><tt>['haproxy']['defaults']</tt></td>
    <td>Hash</td>
    <td>Haproxy defaults parameters</td>
    <td><tt>{ 'log' => 'global', 'mode' => 'http', 'option' => [ 'httplog', 'dontlognull', 'redispatch' ], 'retries' =>  3, 'maxconn' => 2000, 'timeout' => { 'connect' => 50000, 'client' => 50000, 'server' => 50000 } }</tt></td>
  </tr>
  <tr>
    <td><tt>['haproxy']['frontend']</tt></td>
    <td>Hash</td>
    <td>Haproxy frontends</td>
    <td><tt>{}</tt></td>
  </tr>
  <tr>
    <td><tt>['haproxy']['backend']</tt></td>
    <td>Hash</td>
    <td>Haproxy backends</td>
    <td><tt>{}</tt></td>
  </tr>
  <tr>
    <td><tt>['haproxy']['listen']</tt></td>
    <td>Hash</td>
    <td>Haproxy listens</td>
    <td><tt>{}</tt></td>
  </tr>
</table>

For more details, see the `attributes/default.rb` file.

## Recipes

### haproxy_reloaded::default
This recipe installs and configures Haproxy in the node.

## Resources and Providers

There are **none** defined.

## Libraries

### haproxy_reloaded::generate_content
This library contains the functions that parse the node attributes and generate the haproxy configuration file.

## Usage

Just include `haproxy_reloaded` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[haproxy_reloaded]"
  ]
}
```

This cookbook does not have a template file to create the haproxy.cfg file, this file is generated dinamically by parsing the ```['haproxy']``` attribute.

The global, defaults, listens, frontends and backends sections follow the same rules in order to generate the Haproxy configuration file. The idea is generate the config file by setting the attributes in the nodes, roles or environments by avoiding the use of templates.

The attributes ```['haproxy']['listen']```, ```['haproxy']['frontend']``` and ```['haproxy']['backend']``` are hashes of hashes, each key is the name of every section (listen, frontend, backend), and the hash value contains all the settings of this section.

You can disable listen, frontend or backend sections configured in other roles by setting them to false, for example: ```['haproxy']['backend']['riak'] = false```

The special attribute ```[member_options]``` is an hash that set rules to search the servers and the configurations to be applied them by setting the following attributes:

- ```[member_options]['search']```: You need to define the Chef search string in order to obtain the nodes IP that will be used in the Haproxy server parameters
- ```[member_options]['search_extra_environments']```: You can extend the search query to other chef environments than the node's one. This allows you to send the same trafic to multiple clusters. (Default is `nil`)
- ```[member_options]['search_environments']```: You can also completely replace the chef environments used to search for the nodes. This allows you to send different trafics to different clusters. (Default is `nil`)
- ```[member_options]['port']```:  You should set the port where is running the nodes service that will be managed by Haproxy
- ```[member_options]['options']```: This attribute should contain all the options that you need to set to the servers

These are the rules to generate the config file regarding to the values of each attribute if the type of them are:
- Boolean: The parser adds only the name of the attribute (the hash key). For example, if

```ruby
['haproxy']['global']['quiet'] = true
```
the parser generates:
```
global
	quiet
```

- String/Numeric: The parser adds the name of the attribute (the hash key) and the value. For example, if

```ruby
['haproxy']['global']['maxconn'] = 4096
```
the parser generates:
```
global
        maxconn 4096
```

- Array: The parser adds the name of the attribute (the hash key) before of each parsed item of the array. For example, if

```ruby
['haproxy']['defaults']['option'] = [ 'dontlognull', 'http-server-close', 'contstats', 'httplog' ]
```
the parser generates:
```
defaults
	option dontlognull
	option http-server-close
	option contstats
	option httplog
```

- Hash: The parser adds the name of the attribute (the hash key) before of each parsed pair of keys and values of the hash. For example, if 

```ruby
['haproxy']['defaults']['timeout'] = { 
  'connect' => '5s', 
  'client' => '30s', 
  'client-fin' => '30s', 
  'server' => '30s', 
  'tunnel' => '1h', 
  'http-keep-alive' => '1s', 
  'http-request' => '15s', 
  'queue' => '30s', 
  'tarpit' => '60s' 
}
``` 
the parser generates:
```
defaults
        timeout connect 5s
        timeout client 30s
        timeout client-fin 30s
        timeout server 30s
        timeout tunnel 1h
        timeout http-keep-alive 1s
        timeout http-request 15s
	timeout queue 30s
	timeout tarpit 60s
```

**NOTE**: Each value is parsed recursively so you can combine arrays, hashes, strings, booleans, etc. For example, if

```ruby
['haproxy']['frontend']['http-www']['http-request'] = { 
  'set-header' => { 
    'X-LXLX' => [ 'lala if acl-lala', 'lolo if acl-lolo', 'lele if acl-lele' ],
    'X-PERSISTENT' => 'Joya',
    'X-Haproxy-Current-Date %T' => true
  },
  'add-header' => [ 'X-ADDED dePrepo' ],
  'redirect' => 'code 301 location https://example.com.ar%[capture.req.uri] unless valid_domain',
  'allow' => {
    'if' => {
      'nagios' => false,
      'sensu' => true
    }
  }
}
```
the parser generates:
```
frontend http-www
	http-request set-header X-LXLX lala if acl-lala
	http-request set-header X-LXLX lolo if acl-lolo
	http-request set-header X-LXLX lele if acl-lele
        http-request set-header X-PERSISTENT Joya
        http-request set-header X-Haproxy-Current-Date %T
        http-request add-header X-ADDED dePrepo
        http-request redirect code 301 location https://example.com.ar%[capture.req.uri] unless valid_domain
        http-request allow if sensu
```

Also, the parser can read the values of the node attributes set in a role and the values of the attributes of the nodes obtained by using the Chef search query set in the ```[member_options]['search']``` attribute: 

- For example, if an value of an attribute is set in a role and a subattribute of the ```['haproxy']``` attribute is a string that contains `#{node['some']['node']['attribute']}` the parser will replace it with the value of this node attribute:

```json
"apache": {
  "listen_ports": 80
},
"haproxy": {
  "frontend": {
    "http-www": {
      "bind": "#{node['ipaddress']}:#{node['apache']['listen_ports']}"
    }
  }
}
```
the parser will generate:
```
frontend http-www
	bind 1.1.1.1:80
```

- If you need to set some server option by uisng some attribute of the nodes obtained in the Chef search query, you can use the following string `#{server['some']['node']['attribute']}`: 

```json
"haproxy": {
  "backend": {
    "webstomp": {
      "servers": {
        "search": "role:webstomp",
        "port": "15674",
        "options": "inter 3s rise 2 fall 3 weight 10 cookie #{server['fqdn']} check"
      }
    }
  }
}
```
the parser will generate:
```
backend webstomp
	server  webstomp00 1.1.1.2:15674 inter 3s rise 2 fall 3 weight 10 cookie webstomp00.example.com check
        server  webstomp01 1.1.1.3:15674 inter 3s rise 2 fall 3 weight 10 cookie webstomp01.example.com check
``` 

Putting all toghether, the following settings:

```json
"haproxy": {
  "daemon": {
    "enable": true,
    "extra_options": false
  },
  "global": {
    "log": {
      "/dev/log": [ "local0", "local1 notice" ]
    },
    "maxconn": 4096,
    "debug": false,
    "quiet": false,
    "user": "haproxy",
    "group": "haproxy",
    "stats": {
      "socket": "/var/run/haproxy/admin.sock mode 660 level admin",
      "timeout": "30s"
    },
    "daemon": true,
    "ca-base": "/etc/ssl/certs",
    "crt-base": "/etc/ssl/private",
    "ssl-default-bind-ciphers": "kEECDH+aRSA+AES:kRSA+AES:+AES256:RC4-SHA:!kEDH:!LOW:!EXP:!MD5:!aNULL:!eNULL"
  },
  "defaults": {
    "log": "global",
    "mode": "http",
    "option": [ "httplog", "dontlognull", "redispatch", "dontlog-normal", "http-server-close", "contstats" ],
    "retries": 3,
    "maxconn": "32768",
    "timeout": {
      "connect": "5s",
      "client": "60s",
      "client-fin": "60s",
      "server": "60s",
      "tunnel": "1h",
      "http-keep-alive": "1s",
      "http-request": "30s",
      "queue": "30s",
      "tarpit": "60s"
    },
    "backlog": "10000",
    "errorfile": {
      "400": "/etc/haproxy/errors/landing-page/index.http",
      "403": "/etc/haproxy/errors/landing-page/index.http",
      "408": "/dev/null",
      "500": "/etc/haproxy/errors/landing-page/index.http",
      "502": "/etc/haproxy/errors/landing-page/index.http",
      "503": "/etc/haproxy/errors/landing-page/index.http",
      "504": "/etc/haproxy/errors/landing-page/index.http"
    }
  },
  "frontend": {
    "riak_frontend": {
      "bind": "1.1.1.1:8087",
      "mode": "tcp",
      "option": [ "tcplog", "tcpka" ],
      "default_backend": "riak_backend"
    },
    "rabbitmq": {
      "bind": "1.1.1.2:5672",
      "mode": "tcp",
      "option": [ "tcplog", "clitcpka" ],
      "default_backend": "rabbitmq_backend"
    },
    "http-www": {
      "bind": "2.2.2.2:80",
      "redirect": "scheme https code 301 if !{ ssl_fc }"
    },
    "https-www": {
      "bind": "2.2.2.2:443 ssl crt /etc/haproxy/ssl/snakeoil.pem no-sslv3",
      "acl": [ "ajax req.hdr(X-Requested-With) -i XMLHttpRequest", "webstomp base_sub -i /webstomp/" ],
      "reqadd": "X-Forwarded-Proto:\\ https",
      "default_backend": "www_backend",
      "option": [ "forwardfor" ],
      "use_backend": [ "webstomp_backend if webstomp" ]
        
    }
  },
  "backend": {
    "www_backend": {
      "balance": "roundrobin",
      "option": [ "httpclose" ],
      "servers": {
        "search": "role:www",
        "port": "#{server['apache']['listen_ports']}",
        "options": "check port #{server['apache']['listen_ports']}"
      }
    },
    "webstomp_backend": {
      "balance": "roundrobin",
      "servers": {
        "search": "role:webstomp",
        "port": "15674",
        "options": "inter 3s rise 2 fall 3 weight 10 cookie #{server['hostname']} check"
      }
    },
    "riak_backend": {
      "balance": "leastconn",
      "mode": "tcp",
      "option": [ "tcplog", "tcpka", "srvtcpka" ],
      "servers": {
        "search": "role:riak",
        "port": "8087",
        "options": "weight 1 maxconn 1024 check"
      }
    },
    "rabbitmq_backend": {
      "balance": "roundrobin",
      "mode": "tcp",
      "option": [ "srvtcpka", "tcplog" ],
      "timeout": [ "server 3h" ],
      "servers": {
        "search": "role:rabbitmq",
        "port": "5672",
        "options": "check inter 5s rise 2 fall 3"
      }
    }
  },
  "listen": {
    "some_listen_set_in_other_role": false,
    "stats": {
      "bind": "#{node['ipaddress']}:9090",
      "stats": {
        "uri": "/stats",
        "realm": "HAProxy\\ Statistics",
        "auth": "admin:admin",
        "admin": "if TRUE"
      }
    },
    "health": {
      "bind": "127.0.0.1:6000",
      "mode": "health",
      "option": [ "tcplog" ]
    }
  }
}
```
will generate the following configuration file:

```
global
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private
        daemon
        user haproxy
        group haproxy
        log /dev/log local0
        log /dev/log local1 notice
        maxconn 4096
        ssl-default-bind-ciphers kEECDH+aRSA+AES:kRSA+AES:+AES256:RC4-SHA:!kEDH:!LOW:!EXP:!MD5:!aNULL:!eNULL
        stats socket /var/run/haproxy/admin.sock mode 660 level admin
        stats timeout 30s

defaults
        backlog 10000
        errorfile 400 /etc/haproxy/errors/landing-page/index.http
        errorfile 403 /etc/haproxy/errors/landing-page/index.http
        errorfile 408 /dev/null
        errorfile 500 /etc/haproxy/errors/landing-page/index.http
        errorfile 502 /etc/haproxy/errors/landing-page/index.http
        errorfile 503 /etc/haproxy/errors/landing-page/index.http
        errorfile 504 /etc/haproxy/errors/landing-page/index.http
        log global
        maxconn 32768
        mode http
        option httplog
        option dontlognull
        option redispatch
        option dontlog-normal
        option http-server-close
        option contstats
        retries 3
        timeout client 60s
        timeout client-fin 60s
        timeout connect 5s
        timeout http-keep-alive 1s
        timeout http-request 30s
        timeout queue 30s
        timeout server 60s
        timeout tarpit 60s
        timeout tunnel 1h

frontend riak
        bind 1.1.1.1:8087
        default_backend riak_backend
        mode tcp
        option tcplog
        option tcpka

frontend rabbitmq
        bind 1.1.1.2:5672
        default_backend rabbitmq_backend
        mode tcp
        option tcplog
        option clitcpka

frontend www
        bind 2.2.2.2:80
        redirect scheme https code 301 if !{ ssl_fc }

frontend https_www
        acl ajax req.hdr(X-Requested-With) -i XMLHttpRequest
        acl stomp base_sub -i /stomp/
        bind 2.2.2.2:443 ssl crt /etc/haproxy/ssl/snakeoil.pem no-sslv3
        default_backend www_backend
        option forwardfor
        reqadd X-Forwarded-Proto:\ https
        use_backend webstomp_backend if webstomp

backend www_backend
        balance roundrobin
        option httpclose
        server  www00 1.1.1.10:80 check port 80
        server  www01 1.1.1.11:80 check port 80

backend webstomp_backend
        balance roundrobin
        reqadd X-Forwarded-Proto:\ https
        server  webstomp00 1.1.1.20:15674 inter 3s rise 2 fall 3 weight 10 cookie webstomp00 check
        server  webstomp01 1.1.1.21:15674 inter 3s rise 2 fall 3 weight 10 cookie webstomp01 check

backend riak_backend
        balance leastconn
        mode tcp
        option tcplog
        option tcpka
        option srvtcpka
        server  riak00 1.1.1.70:8087 weight 1 maxconn 1024 check
        server  riak01 1.1.1.71:8087 weight 1 maxconn 1024 check
        server  riak02 1.1.1.72:8087 weight 1 maxconn 1024 check
        server  riak03 1.1.1.73:8087 weight 1 maxconn 1024 check
        server  riak04 1.1.1.74:8087 weight 1 maxconn 1024 check

backend rabbitmq_backend
        balance roundrobin
        mode tcp
        option srvtcpka
        option tcplog
        timeout server 3h
        server  rabbitmq00 1.1.1.50:5672 check inter 5s rise 2 fall 3
        server  rabbitmq01 1.1.1.51:5672 check inter 5s rise 2 fall 3

listen stats
        balance
        bind 1.1.1.10:9090
        stats admin if TRUE
        stats auth admin:admin
        stats realm HAProxy\ Statistics
        stats uri /stats

listen health
        bind 127.0.0.1:6000
        mode health
        option tcplog
```

### Forwarding the same trafic to multiple clusters

By default this cookbook will scope the `search` with the node's chef
environment, but you can enlarge the search scope by adding more chef 
environments in the `search_extra_environments` attribute:

```json
"haproxy": {
  "frontend": {
    "http": {
      "bind": "*:80",
      "default_backend": "webstomp"
    }
  },
  "backend": {
    "webstomp": {
      "servers": {
        "search": "policy_name:k8sworker",
        "search_extra_environments": ["staging-west"]
      }
    }
  }
}
```

Let's suppose that the trafic for `a.example.com` and `b.example.com` is coming
to the load balancer port 80, both will be forwarded to the servers from the
`webstomp` backend.

### Forwarding different trafics to different clusters

But you can also completely replace the chef environments used in the search 
query in order to *split* the trafic:

```json
"haproxy": {
  "frontend": {
    "http": {
      "bind": "*:80",
      "use_backend": "%[req.hdr(host),lower,word(1,:)]"
    }
  },
  "backend": {
    "a.example.com": {
      "servers": {
        "search": "policy_name:k8sworker",
        "search_environments": ["staging-app-a"]
      }
    },
    "b.example.com": {
      "servers": {
        "search": "policy_name:k8sworker",
        "search_environments": ["staging-app-b"]
      }
    }
  }
```

Here the trafic to `a.example.com` will be forwarded to the nodes from the
`staging-app-a` chef environment (or policy group), while the trafic to 
`b.example.com` will be forwarded to the nodes from the `staging-app-b` chef 
environment (or policy group).

## Development

- Source hosted at [GitHub][repo]
- Report issues/Questions/Feature requests on [GitHub Issues][issues]

Contributing
------------

1. Fork the repository on [Github][repo]
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------

Author:: Claudio Cesar Sanchez Tejeda <demonccc@gmail.com>

Copyright:: 2014, Claudio Cesar Sanchez Tejeda

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[repo]: https://github.com/demonccc/chef-haproxy_reloaded
[issues]: https://github.com/demonccc/chef-haproxy_reloaded/issues
