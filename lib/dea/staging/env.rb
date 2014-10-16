# coding: UTF-8
require 'URI'

module Dea
  module Staging
    class Env
      attr_reader :message, :staging_task

      def initialize(message, staging_task)
        @message = message.start_message
        @staging_task = staging_task
      end

      def system_environment_variables
        array = [
          ["BUILDPACK_CACHE", staging_task.staging_config["environment"]["BUILDPACK_CACHE"]],
          ["STAGING_TIMEOUT", staging_task.staging_timeout],
          ["MEMORY_LIMIT", "#{message.mem_limit}m"]
        ]
        if staging_task.staging_config["http_proxy"]
          
          uri = URI(staging_task.staging_config["http_proxy"])
          
          port = uri.port
          unless port
            port=80
          end
            
          java_opts = "-Dhttp.proxyHost=#{uri.host} -Dhttp.proxyPort=#{port}"
          
          if uri.userinfo
            username, password = uri.userinfo.split(':')
            java_opts = "#{java_opts} -Dhttp.proxyHost=#{uri.host} -Dhttp.proxyPort=#{uri.port}"
          end
          
          array << ["JAVA_OPTS", java_opts]
          array << ["HTTP_PROXY", staging_task.staging_config["http_proxy"]]
          array << ["http_proxy", staging_task.staging_config["http_proxy"]]
          array << ["HTTPS_PROXY", staging_task.staging_config["http_proxy"]]
          array << ["https_proxy", staging_task.staging_config["http_proxy"]]
        end
        array
      end

      def vcap_application
        {}
      end
      
      def instance_zone
        @staging_task.instance_zone
      end
    end
  end
end
