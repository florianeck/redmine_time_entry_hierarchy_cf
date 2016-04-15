require File.expand_path("../../spec_helper", __FILE__)

RSpec.describe TimeEntryHierarchyCf do

  specify "module constants" do
    expect(described_class::ALLOWED_FIRST_LEVEL_KEYS).to eq(%w(project issue))
    expect(described_class::CONFIG_FILE_PATH).to eq("#{Rails.root}/config/time_entry_hierarchy_cf.yml")
  end

  specify "cattr_reader :yaml_config" do
    expect(described_class).to respond_to(:yaml_config)
  end

  context ".config_from_yaml" do

    context "loads file from CONFIG_FILE_PATH path" do
      let!(:dummy_config_path) { File.expand_path("../../fixtures/spec_config.yml", __FILE__) }
      let!(:dummy_yaml)   { YAML::load(File.open(dummy_config_path).read) }

      context "assigns it to @@yaml_config" do
        before do
          expect(File).to receive(:exists?).with(described_class::CONFIG_FILE_PATH).and_return(true)
          expect(File).to receive(:open).with(described_class::CONFIG_FILE_PATH).and_return(File.open(dummy_config_path))
          described_class.config_from_yaml
        end

        specify { expect(described_class.yaml_config).to eq(dummy_yaml) }
      end

      context "load from @@yaml_config if already present" do
        before do
          expect(described_class).to receive(:yaml_config).exactly(2).times.and_return(dummy_yaml)
        end

        specify { expect(described_class.config_from_yaml).to eq(dummy_yaml)}
      end

      context "raises error if no config file is present" do
        before do
          expect(File).to receive(:exists?).with(described_class::CONFIG_FILE_PATH).and_return(false)
          expect(described_class).to receive(:yaml_config).exactly(1).times.and_return(nil)
        end

        specify do
          expect { described_class.config_from_yaml }.to raise_error(LoadError, "Cant find config file under #{described_class::CONFIG_FILE_PATH}")
        end
      end
    end

  end

end

# module TimeEntryHierarchyCf
#
#
#   class << self

#     end
#
#     def config_valid?
#       # checking for first level keys
#       if (config_from_yaml.keys - ALLOWED_FIRST_LEVEL_KEYS).any?
#         raise ArgumentError, "Invalid first-level keys in config: #{(config_from_yaml.keys - ALLOWED_FIRST_LEVEL_KEYS).inspect}"
#       end
#
#       return true
#     end
#
#     def create_custom_field!(type, field_name)
#       entry = custom_field_class_for(type, field_name).create(custom_field_attributes_for(type, field_name))
#
#       if entry.persisted?
#         TimeEntryCustomField.create(custom_field_attributes_for(type, field_name, for_time_entry: true))
#       end
#
#       return entry
#     end
#
#     def custom_field_attributes_for(type, field_name, options = {for_time_entry: false})
#       full_field_name = Naming.send((options[:for_time_entry] ? :time_entry_internal_name_for : :internal_name_for), type, field_name)
#
#       config_from_yaml[type]['fields'][field_name].symbolize_keys.merge({
#         name: "#{full_field_name.first(25)} #{ rand(1000)}", internal_name: full_field_name
#       })
#     end
#
#     def custom_field_class_for(type, field_name)
#       "#{type}_custom_field".camelize.constantize
#     end
#
#     module Naming
#       def self.internal_name_for(type, field_name)
#         "#{type}_#{field_name}"
#       end
#
#       def self.time_entry_internal_name_for(type, field_name)
#         "time_entry_#{field_name}_from_#{type}"
#       end
#     end
#
#   end
#
# end