
require 'chef/resource'

class Chef
  class Resource
    class NginxConfig < Chef::Resource

      def initialize(name, run_context=nil)
        super
        @action = :register
        @allowed_actions = [:create, :destroy, :register]
        @provider = Chef::Provider::NginxConfig
      end

      def cookbook(arg=nil)
        set_or_return(:cookbook, arg, :kind_of => [String])
      end

      def template(arg=nil)
        set_or_return(:template, arg, :kind_of => [String])
      end

      def options(arg=nil)
        set_or_return(:options, arg, :kind_of => [Hash])
      end

    end
  end
end
