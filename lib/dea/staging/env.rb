# coding: UTF-8
require 'uri'

module Dea
  module Staging
    class Env
      attr_reader :message, :staging_task

      def initialize(message, staging_task)
        @message = message
        @staging_task = staging_task
      end

      def system_environment_variables
        array = [
          ["STAGING_TIMEOUT", staging_task.staging_timeout],
          ["MEMORY_LIMIT", "#{message.mem_limit}m"]
        ]

        if staging_task.staging_config["http_proxy"]
          
          uri = URI(staging_task.staging_config["http_proxy"])
          raise 'Missing user info'  unless uri.userinfo

          username, password = uri.userinfo.split(':')

          java_opts = "-Dhttp.proxyHost=#{uri.host} -Dhttp.proxyPort=#{uri.port} -Dhttp.proxyUser=#{username} -Dhttp.proxyPassword=#{password}"

          array << ["JAVA_OPTS", java_opts]
          array << ["HTTP_PROXY", staging_task.staging_config["http_proxy"]]
          array << ["http_proxy", staging_task.staging_config["http_proxy"]]
          array << ["HTTPS_PROXY", staging_task.staging_config["http_proxy"]]
          array << ["https_proxy", staging_task.staging_config["http_proxy"]]


          # Heroku scala buildpack takes SBT_OPTS env var containing a list of java properties prefixed with -J
          # https://github.com/heroku/heroku-buildpack-scala
          sbt_opts = "-J-Dhttp.proxyHost=#{uri.host} -J-Dhttp.proxyPort=#{uri.port} -J-Dhttp.proxyUser=#{username} -J-Dhttp.proxyPassword=#{password}"
          array << ["SBT_OPTS", sbt_opts]
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
