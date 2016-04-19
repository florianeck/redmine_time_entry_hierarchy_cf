require File.expand_path("../../../spec_helper", __FILE__)

RSpec.describe TimeEntryHierarchyCf::ProjectIssueCustomFields do

  let!(:dummy_config_path) { File.expand_path("../../../fixtures/spec_config.yml", __FILE__) }
  let!(:dummy_yaml)   { YAML::load(File.open(dummy_config_path).read) }

  before do
    allow(TimeEntryHierarchyCf).to receive(:yaml_config).and_return(dummy_yaml)
    TimeEntryHierarchyCf.create_custom_field!('project', 'first_field')
  end

  specify "module is included in TimeEntry class" do
    expect(TimeEntry.included_modules).to include(described_class)
  end


  describe "#custom_fields_data_fields_for" do
    let(:time_entry) { build(:time_entry) }

    specify "provides source field for project" do
      expect(time_entry.custom_fields_data_fields_for('project', 'first_field')[:source]).to be_a(ProjectCustomField)
    end

    specify "provides dest field for timeentry" do
      expect(time_entry.custom_fields_data_fields_for('project', 'first_field')[:dest]).to be_a(TimeEntryCustomField)
    end
  end

  describe "#get_custom_value_from_object" do

    let!(:fields_data) { time_entry.custom_fields_data_fields_for('project', 'first_field') }

    let(:project) { create(:project, custom_field_values: {
      fields_data[:source].id => "hello"
      })
    }
    let(:time_entry) { build(:time_entry) }


    context "project has custom value for 'first_field'" do

      before do
        binding.pry
        project.custom_value_for(fields_data[:source]).value = "Hello"
        time_entry.get_custom_value_from_object('project', 'first_field')
      end

      specify { expect(time_entry.custom_value_for(fields_data[:dest])).to eq('Hello') }

    end


  end




  after do
    ProjectCustomField.delete_all
    TimeEntryCustomField.delete_all
  end

end

# module TimeEntryHierarchyCf::ProjectIssueCustomFields
#   extend ActiveSupport::Concern
#
#   def custom_fields_for(type, name)
#     {
#       source: ProjectCustomField.find_by_internal_name()
#     }
#   end
#
#   def assign_custom_field_value_from!(type, name)
#     base_object = self.send(type)
#
#     object_field_name     = TimeEntryHierarchyCf::Naming.internal_name_for(type, name)
#     time_entry_field_name = TimeEntryHierarchyCf::Naming.time_entry_internal_name_for(type, name)
#
#     # ingnore is object not given
#     if base_object
#
#     end
#   end
#
#   # this will be called recursively if required
#   def get_custom_value_from_object(object, object_field_name)
#
#   end
#
# end