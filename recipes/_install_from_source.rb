# Cookbook Name:: nginx
# Recipe:: _install_from_source
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

include_recipe 'build-essential'

case node['platform_family']
when 'rhel'
  build_pkgs = %w( openssl-dev )
when 'debian'
  build_pkgs = %w( libssl-dev )
end

unless node['nginx']['build_packages'].nil?
  node['nginx']['build_packages'].each { |bp| build_pkgs << bp }
end

build_pkgs.each { |pkg| package pkg }

user_autoconf_options = [
  "--prefix=#{ node['nginx']['prefix_dir'] }",
  "--conf-path=#{ node['nginx']['sysconf_dir'] }",
  "--sbin-path=#{ node['nginx']['sbin_dir'] }",
  "--error-log=#{ node['nginx']['log_dir'] }",
  "--pid-path=#{ node['nginx']['run_dir'] }",
  "--lock-path=#{ node['nginx']['lock_dir'] }"
]

unless node['nginx']['autoconf_opts'].nil?
  node['nginx']['autoconf_opts'].each { |aco| user_autoconf_options << aco }
end

nginx_src_url = "#{ node['nginx']['src_url_prefix'] }/#{ node['nginx']['src_file_prefix'] }#{ node['nginx']['version'] }#{ node['nginx']['src_file_ext'] }"

ark 'nginx' do
  url nginx_src_url
  version node['nginx']['version']
  checksum node['nginx']['checksum']
  autoconf_opts user_autoconf_options
  prefix_root node['nginx']['prefix_dir']
  path node['nginx']['src_dir']
  action [ :configure, :install_with_make ]
end
