module TimeEntryHierarchyCf

  CONFIG_FILE_PATH         = File.expand_path("../../config/time_entry_hierarchy_cf.yml", __FILE__)

  cattr_reader :yaml_config

  class << self

    def custom_field_models
      [Project, Issue, TimeEntry]
    end

    def config_from_yaml
      return self.yaml_config if self.yaml_config.present?

      if File.exists?(CONFIG_FILE_PATH)
        @@yaml_config = YAML::load(File.open(CONFIG_FILE_PATH).read)
      else
        raise LoadError, "Cant find config file under #{CONFIG_FILE_PATH}"
      end
    end

    def config_valid?
      config_from_yaml.each do |field_name, settings|
        raise ArgumentError, "'#{field_name}' setttings must be a hash" if !settings.is_a?(Hash)
        raise ArgumentError, "Missing :field_format for '#{field_name}'" if settings['field_format'].nil?
      end

      return true
    end

    def create_custom_field!(field_name)
      entries = {}
      self.custom_field_models.each do |model|
        # Checking if entry already exists
        next if custom_field_class_for(model).find_by_internal_name(Naming.internal_name_for(model, field_name)).present?
        entries[model.name] = custom_field_class_for(model).create(custom_field_attributes_for(model, field_name))
      end

      return entries
    end

    def custom_field_attributes_for(field_class, field_name)
      full_field_name = Naming.internal_name_for(field_class, field_name)

      config_from_yaml[field_name].symbolize_keys.except(:internal_name, :fallbacks).merge({
        name: "#{full_field_name.first(25)} #{ rand(1000)}", internal_name: full_field_name
      })
    end

    def custom_field_class_for(field_class)
      "#{field_class}CustomField".camelize.constantize
    end
    
    def get_fallback_value_for(obj, field_name)
      if config_from_yaml[field_name]
        send_chain(obj, config_from_yaml[field_name]['fallbacks'].try(:[], obj.class.name.underscore))
      end
    end
  end

  module Naming
    def self.internal_name_for(field_class, field_name)
      "#{field_class.name.underscore}_#{field_name}"
    end
  end
  
  def self.send_chain(obj, chain)
    return if chain.blank?
    value = obj
    chain.split('.').each do |a|
      value = value.try(a)  
    end
    
    return value
  end
  
end