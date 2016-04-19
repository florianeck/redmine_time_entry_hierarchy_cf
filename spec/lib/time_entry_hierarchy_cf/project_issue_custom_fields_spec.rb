require File.expand_path("../../../spec_helper", __FILE__)

RSpec.describe TimeEntryHierarchyCf::ProjectIssueCustomFields do

  let!(:dummy_config_path) { File.expand_path("../../../fixtures/spec_config.yml", __FILE__) }
  let!(:dummy_yaml)   { YAML::load(File.open(dummy_config_path).read) }

  let(:root_project)    { create(:project, name: "my root project") }

  before do
    allow(TimeEntryHierarchyCf).to receive(:yaml_config).and_return(dummy_yaml)
    TimeEntryHierarchyCf.create_custom_field!('first_field')
  end

  specify "module is included in TimeEntry class" do
    expect(TimeEntry.included_modules).to include(described_class)
  end


  describe "#assign_time_entry_custom_field" do
    let(:time_entry) { build(:time_entry, project: root_project) }

    before do
      # skip activity_id validation
      time_entry.send(:assign_time_entry_custom_field, 'first_field', 'Hey!')
    end

    specify do
      binding.pry
    end

  end

  # def assign_time_entry_custom_field(name, value)
#     self.custom_field_values.select {|f| f.custom_field.internal_name == TimeEntryHierarchyCf::Naming.internal_name_for(self.class, name)}.first.try("value=", value  )
#   end


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