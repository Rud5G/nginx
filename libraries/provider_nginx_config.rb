
require 'chef/provider'

class Chef
  class Provider
    class NginxConfig < Chef::Provider

      def initialize(*args)
        super
      end

      def load_current_resource
        @current_resource = Chef::Resource::NginxConfig.new(new_resource.name)
        @current_resource.cookbook(new_resource.cookbook)
        @current_resource.options(new_resource.options)
        @current_resource.template(new_resource.terminate)

        @current_resource.created(created?)

        @current_resource
      end

      def action_create
      end

      def action_destroy
      end

      def action_register
      end

    end
  end
end
