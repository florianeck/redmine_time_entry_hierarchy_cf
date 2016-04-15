require File.expand_path("../../spec_helper", __FILE__)

RSpec.describe TimeEntryHierarchyCf do

  let!(:dummy_config_path) { File.expand_path("../../fixtures/spec_config.yml", __FILE__) }
  let!(:dummy_yaml)   { YAML::load(File.open(dummy_config_path).read) }

  specify "module constants" do
    expect(described_class::ALLOWED_FIRST_LEVEL_KEYS).to eq(%w(project issue))
    expect(described_class::CONFIG_FILE_PATH).to eq("#{Rails.root}/config/time_entry_hierarchy_cf.yml")
  end

  specify "cattr_reader :yaml_config" do
    expect(described_class).to respond_to(:yaml_config)
  end

  describe ".config_from_yaml" do
    context "loads file from CONFIG_FILE_PATH path" do
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

  describe ".config_valid?" do
    context "with valid config" do
      before do
        allow(described_class).to receive(:yaml_config).and_return(dummy_yaml)
      end
      specify { expect(described_class.config_valid?).to be(true)}
    end

    context "with invalid config" do
      before do
        allow(described_class).to receive(:yaml_config).and_return({'some' => 'key'})
      end
      specify do
        expect { described_class.config_valid? }.to raise_error(ArgumentError, "Invalid first-level keys in config: [\"some\"]")
      end
    end
  end

  describe ".create_custom_field!" do
    before do
      allow(described_class).to receive(:yaml_config).and_return(dummy_yaml)
      described_class.create_custom_field!('project', 'first_field')
    end

    specify 'creates a ProjectCustomField' do
      expect(ProjectCustomField.find_by_internal_name(described_class::Naming.internal_name_for('project', 'first_field'))).not_to be(nil)
    end

    specify 'creates a TimeEntryCustomField' do
      expect(TimeEntryCustomField.find_by_internal_name(described_class::Naming.time_entry_internal_name_for('project', 'first_field'))).not_to be(nil)
    end

    after do
      ProjectCustomField.delete_all
      TimeEntryCustomField.delete_all
    end
  end

  describe ".custom_field_attributes_for" do
    before { allow(described_class).to receive(:yaml_config).and_return(dummy_yaml) }

    specify 'for Project field' do
      expect(described_class.custom_field_attributes_for('project', 'first_field')[:field_format]).to eq('string')
      expect(described_class.custom_field_attributes_for('project', 'first_field')[:is_required]).to eq(true)
      expect(described_class.custom_field_attributes_for('project', 'first_field')[:internal_name]).to eq('project_first_field')
    end

    specify 'for TimeEntry field' do
      expect(described_class.custom_field_attributes_for('project', 'first_field', for_time_entry: true)[:field_format]).to eq('string')
      expect(described_class.custom_field_attributes_for('project', 'first_field', for_time_entry: true)[:is_required]).to eq(true)
      expect(described_class.custom_field_attributes_for('project', 'first_field', for_time_entry: true)[:internal_name]).to eq('time_entry_first_field_from_project')
    end
  end

end
