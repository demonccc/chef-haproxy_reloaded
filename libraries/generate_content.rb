def generate_content(hash, prefix="")
  output = ""
  hash = hash.sort
  hash.each do |k,v|
    unless k.eql?("servers")
      case v
      when Array
        v.each { |x| output += "        #{prefix}#{k} #{x}\n" }
      when Hash
        output += generate_content(v, "#{k} ")
      when TrueClass
        output += "        #{prefix}#{k}\n"
      when FalseClass
        output += ""
      when Fixnum
        output += "        #{prefix}#{k} #{v}\n"
      else
        output += "        #{prefix}#{k} #{parse_value(v)}\n"
      end
    end
  end
  return output
end

def parse_value(value, server={})
  output = value
  match = /(.*)\#\{(.*)\}(.*)/.match(value)
  if match
    eval("output = \"#{match[1]}\#\{#{match[2]}\}#{match[3]}\"")
  end
  return output
end

def parse_servers_hash(servers)
  output = ''
  server_options = ''
  server_options = ":#{servers['port']}" unless servers['port'].nil?
  server_options += " #{servers['options']}" unless servers['options'].nil?

  if servers['options_per_node']
    servers['per_node']['nodes'].each do |n|
      server_options += " #{servers['per_node']['options']}" if node['name'] == n
    end
  end

  unless servers['search'].nil?
    if servers['search_extra_environments'] && servers['search_environments']
      Chef::Log.fatal 'Configuration with both search_extra_environments AND ' \
                      'search_environments is not supported.'
      raise
    end

    chef_environments = "chef_environment:#{node.chef_environment}"

    unless servers['search_extra_environments'].nil?
      servers['search_extra_environments'].map do |extra_env|
        chef_environments += " OR chef_environment:#{extra_env}"
      end
    end

    unless servers['search_environments'].nil?
      chef_environments = ''

      servers['search_environments'].each_with_index do |extra_env, index|
        chef_environments += "chef_environment:#{extra_env}"

        chef_environments += ' OR ' if index < servers['search_environments'].size
      end
    end

    Chef::Log.info "\n  )-----> chef_environments: #{chef_environments.inspect}"

    pool_servers = search('node', "#{servers['search']} AND (#{chef_environments})") || []

    pool_servers = pool_servers.sort { |a, b| a[:hostname] <=> b[:hostname] }

    pool_servers.map! do |server|
      begin
        if server['cloud']
          if node['cloud'] && (server['cloud']['provider'] == node['cloud']['provider'])
            server['cloud']['local_ipv4']
          else
            server['cloud']['public_ipv4']
          end
        else
          server['ipaddress']
        end
      end
      output += "        server  #{server['hostname']} #{server['ipaddress']}#{parse_value(server_options, server)}\n"
    end
  end

  output
end
