#!/usr/bin/env ruby
require 'yaml'

STDOUT.sync = true

def main()
  firewall_env = ARGV[0]

  nb_config_locations = [
    "/app/nb-config",
    "/app/tomcat/webapps/ROOT/nb-config"
  ]

  firewall_file = ""
  nb_config_locations.each do |location|
    if File.exists?(File.join(location, 'backends-default.yml'))
      firewall_file=File.join(location, 'backends-default.yml')
    end
    if firewall_env and File.exists?(File.join(location, "backends-#{firewall_env}.yml"))
      firewall_file=File.join(location, "backends-#{firewall_env}.yml")
    end
  end

  if firewall_file == ""
    exit 0 
  end

  begin
    backends = File.open(firewall_file) do |f|
      YAML.load(f)
    end

    if backends['backends']
      backends['backends'].each do |backend|
        port=backend['port']
        port or next
        port=port.to_i()
        unless port>=0 and port<64000
          puts "Port is invalid for backend!! (#{port})"
          exit 1
        end

        if backend['destination'] then
          backend['destination'].each do |location|
            if location['ip']=~/^(([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5]))$/
              puts "#{location['ip']}:#{port}"
            end
          end
        end
      end
    end
  rescue Exception => e
    puts "User firewalls failed! (#{e.backtrace().join("\n")})"
    exit 1
  end
  exit 0
end

main()
