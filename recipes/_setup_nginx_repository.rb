# Cookbook Name:: nginx
# Recipe:: _setup_nginx_package
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

case node['platform_family']
when rhel

  rhel_major_release = node['platform_version'].split('.')[0]
  rhel_release = "#{ node['platform_family'] }#{ rhel_major_release }"

  execute 'create-yum-cache' do
    command 'yum -q makecache'
    action :nothing
  end

  ruby_block 'reload-internal-yum-cache' do
    block do
      Chef::Provider::Package::Yum::YumCache.instance.reload
    end
    action :nothing
  end

  yum_key 'nginx-signing-key' do
    url 'http://nginx.org/packages/keys/nginx_signing.key'
    action :add
  end

  yum_repository 'nginx' do
    name 'nginx stable repo'
    url "http://nginx.org/packages/#{ node['platform'] }/#{ rhel_major_release }/$basearch/"
    key 'nginx-signing-key'
    action :add
    notifies :run, "execute[create-yum-cache]", :immediately
    notifies :create, "ruby_block[reload-internal-yum-cache]", :immediately
  end

when debian

  apt_repository 'nginx' do
    uri 'http://nginx.org/packages/debian'
    distribution node['platform']
    components ['nginx']
    key 'http://nginx.org/packages/keys/nginx_signing.key'
  end

end
