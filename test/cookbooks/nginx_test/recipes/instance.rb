package 'nginx' do
  action :nothing
end

execute 'apt-get update' do
  notifies :install, 'package[nginx]', :immediately
end

nginx_config 'example.com' do
  template 'example.com.conf.erb'
end

nginx_instance 'example.com' do
  nginx_bin '/usr/bin/nginx'
  path  '/opt'
  user  'nobody'
  group 'nogroup'
end
