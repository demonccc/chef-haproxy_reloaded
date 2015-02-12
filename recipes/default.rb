#
# Author:: Claudio Cesar Sanchez Tejeda <demonccc@gmail.com>
# Cookbook Name:: haproxy_reloaded
# Recipe:: default
#
# Copyright 2014, Claudio Cesar Sanchez Tejeda
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

haproxy_cfg_config = "# File managed by Chef\n# Don't edit it manually!\n\n"
haproxy_cfg_config += "global\n"
haproxy_cfg_config += generate_content(node['haproxy']['global'])
haproxy_cfg_config += "\ndefaults\n"
haproxy_cfg_config += generate_content(node['haproxy']['defaults'])

%w{ frontend backend listen }.each do |section|
  if node['haproxy'][section].is_a?(Hash)
    node['haproxy'][section].each do |name,hash|
      if hash.is_a?(Hash) 
        haproxy_cfg_config += "\n#{section} #{name}\n"
        haproxy_cfg_config += generate_content(hash)
        haproxy_cfg_config += parse_servers_hash(hash['servers']) unless hash['servers'].nil?
      end
    end
  end
end

package "haproxy" do
  action :install
end

template "/etc/default/haproxy" do
  source "haproxy-default.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[haproxy]"
end

file "/etc/haproxy/haproxy.cfg" do
  owner "root"
  group "root"
  mode 0644
  content  haproxy_cfg_config
  notifies :reload, "service[haproxy]"
end

service "haproxy" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
