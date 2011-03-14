#
# Cookbook Name:: hosts
# Recipe:: default
#
# Copyright 2011, ModCloth, Inc.
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
hosts_from_server = search(:node, "name:[* TO *] ")

ips = []
ec2_ips = []
hosts_from_server.each do |host|
	res = {:hostname => host[:hostname], :fqdn => host[:fqdn], :nodename => host.name.to_s}
	if host['cloud']
		provider = host['cloud']['provider']
		if provider == 'ec2'
			res[:ip_public] = host[:ec2][:public_ipv4] 
			ec2_ips << res
		end
	else
		res[:ip] = host[:ipaddress]
		ips << res 
	end
end

template "/etc/hosts" do
  source "os_x_etc_hosts.erb"
  mode "0644"
  variables(
          :ips => ips,
          :ec2_ips => ec2_ips
  )
end

template "/usr/bin/stab" do
  source "stab.erb"
  mode "0777"
end
