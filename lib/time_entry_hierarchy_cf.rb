module TimeEntryHierarchyCf

  ALLOWED_FIRST_LEVEL_KEYS = %w(project issue)
  CONFIG_FILE_PATH         = "#{Rails.root}/config/time_entry_hierarchy_cf.yml"

  cattr_reader :yaml_config

  class << self
    def config_from_yaml
      return self.yaml_config if self.yaml_config.present?

      if File.exists?(CONFIG_FILE_PATH)
        @@yaml_config = YAML::load(File.open(CONFIG_FILE_PATH).read)
      else
        raise LoadError, "Cant find config file under #{CONFIG_FILE_PATH}"
      end
    end

    def config_valid?
      # checking for first level keys
      if (config_from_yaml.keys - ALLOWED_FIRST_LEVEL_KEYS).any?
        raise ArgumentError, "Invalid first-level keys in config: #{(config_from_yaml.keys - ALLOWED_FIRST_LEVEL_KEYS).inspect}"
      end

      return true
    end

    def create_custom_field!(type, field_name)
      entry = custom_field_class_for(type, field_name).create(custom_field_attributes_for(type, field_name))

      if entry.persisted?
        TimeEntryCustomField.create(custom_field_attributes_for(type, field_name, for_time_entry: true))
      end

      return entry
    end

    def custom_field_attributes_for(type, field_name, options = {for_time_entry: false})
      full_field_name = Naming.send((options[:for_time_entry] ? :time_entry_internal_name_for : :internal_name_for), type, field_name)

      config_from_yaml[type]['fields'][field_name].symbolize_keys.merge({
        name: "#{full_field_name.first(25)} #{ rand(1000)}", internal_name: full_field_name
      })
    end

    def custom_field_class_for(type, field_name)
      "#{type}_custom_field".camelize.constantize
    end

    module Naming
      def self.internal_name_for(type, field_name)
        "#{type}_#{field_name}"
      end

      def self.time_entry_internal_name_for(type, field_name)
        "time_entry_#{field_name}_from_#{type}"
      end
    end

  end

end