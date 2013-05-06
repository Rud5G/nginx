
require 'chef/provider'

class Chef
  class Provider
    class NginxInstance < Chef::Provider

      def initialize(*args)
        super
        @instance_conf_dir = nil
        @instance_dir = nil
        @instance_log_dir = nil
        @nginx_bin = nil
      end

      def whyrun_supported?
        false
      end

      def load_current_resource
        @current_resource = Chef::Resource::NginxInstance.new(new_resource.name)
        @current_resource.group(new_resource.group)
        @current_resource.nginx_bin(new_resource.nginx_bin)
        @current_resource.options(new_resource.options)
        @current_resource.owner(new_resource.owner)
        @current_resource.path(new_resource.path)
        @current_resource.template(new_resource.terminate)

        @current_resource.created(created?)

        @current_resource
      end

      def action_create
        instance_dir.run_action(:create)
        instance_conf_dir.run_action(:create)
        instance_log_dir.run_action(:create)
        @new_resource.created(true)
      end

      def action_destroy
        instance_dir.run_action(:delete)
        instance_conf_dir.run_action(:delete)
        instance_log_dir.run_action(:delete)
      end

      def action_enable
        instance_service.run_action(:enable)
        @new_resource.enabled(true)
      end

      def action_disable
        instance_service.run_action(:disable)
      end

      def action_stop
        instance_service.run_action(:stop)
      end

      def action_start
        instance_service.run_action(:start)
      end

      def action_restart
        instance_service.run_action(:restart)
      end

      private

      def instance_dir
        return @instance_dir unless @instance_dir.nil?
        @instance_dir = Chef::Resource::Directory.new(instance_dir_name, run_context)
        @instance_dir.recursive(true)
        @instance_dir.owner(new_resource.owner)
        @instance_dir.group(new_resource.group)
        @instance_dir.mode(00755)
        @instance_dir
      end

      def instance_conf_dir
        return @instance_conf_dir unless @instance_conf_dir.nil?
        @instance_conf_dir = Chef::Resource::Directory.new(::File.join(instance_dir_name, 'conf'), run_context)
        @instance_conf_dir.recursive(true)
        @instance_conf_dir.owner(new_resource.owner)
        @instance_conf_dir.group(new_resource.group)
        @instance_conf_dir.mode(00755)
        @instance_conf_dir
      end

      def instance_log_dir
        return @instance_log_dir unless @instance_log_dir.nil?
        @instance_log_dir = Chef::Resource::Directory.new(::File.join(instance_dir_name, 'log'), run_context)
        @instance_log_dir.recursive(true)
        @instance_log_dir.owner(new_resource.owner)
        @instance_log_dir.group(new_resource.group)
        @instance_log_dir.mode(00755)
        @instance_log_dir
      end

      def instance_service
        return @instance_service unless @instance_service.nil?
        @instance_service = Chef::Resource::RunitService.new(new_resource.name, run_context)
        @instance_service.service_name("#{ new_resource.name }_nginx")
        @instance_service.sv_templates(true)
        @instance_service.options({
          :nginx_bin => @nginx_bin,
          :path => instance_dir_name
        })
      end

      def instance_dir_name
        ::File.join('', new_resource.path, new_resource.name)
      end

      def created?
        ::File.exists?(instance_dir_name)
      end

      def enabled?
        run_context.resource_collection.find('RunitService', "#{ new_resource.name }_nginx")
      end

    end
  end
end
