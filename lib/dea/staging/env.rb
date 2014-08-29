# coding: UTF-8

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
      end
    end
  end
end
