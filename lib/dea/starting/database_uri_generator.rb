module Dea
  class DatabaseUriGenerator
    VALID_DB_TYPES = %w[mysql mysql2 postgres postgresql db2 informix].freeze
    RAILS_STYLE_DATABASE_TO_ADAPTER_MAPPING = {
      'mysql' => 'mysql2',
      'postgresql' => 'postgres',
      'db2' => 'ibmdb',
      'informix' => 'ibmdb'
    }.freeze

    def initialize(services)
      @services = Array(services).compact || []
    end

    def database_uri
      bound_database_uri
    end

    private

    def bound_database_uri
      if bound_relational_valid_databases.any?
        bound_relational_valid_databases.first
      else
        nil
      end
    end

    def instance_zone
      if (bootstrap.config['placement_properties'])
        bootstrap.config['placement_properties']['zone']
      else
        ""
      end
    end
    
    def bound_relational_valid_databases
      @bound_relational_valid_databases ||= @services.inject([]) do |collection, binding|
        credentials = nil
        if binding["credentials"].has_key?('uri')
          credentials = binding["credentials"]
        elsif svc['credentials'].has_key?(instance_zone) && svc['credentials'][instance_zone].has_key?('uri')
          credentials = binding["credentials"][instance_zone]
        end
          
        if credentials && credentials["uri"]
          (scheme, rest) = credentials["uri"].split(":", 2)
          if scheme && rest
            collection << "#{convert_scheme_to_rails_style_adapter(scheme)}:#{rest}" if VALID_DB_TYPES.include?(scheme)
          end
        end
        collection
      end
    end

    def convert_scheme_to_rails_style_adapter(scheme)
      return RAILS_STYLE_DATABASE_TO_ADAPTER_MAPPING[scheme] if RAILS_STYLE_DATABASE_TO_ADAPTER_MAPPING[scheme]
      scheme
    end
  end
end
