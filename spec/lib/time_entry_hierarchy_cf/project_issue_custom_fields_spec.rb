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

  describe 'is called before save' do
    let(:time_entry) { build(:time_entry, project: root_project, activity_id: root_project.activities.first.id) }
    specify do
      expect(time_entry).to receive(:assign_all_hierarchic_custom_fields)
      time_entry.save
    end
  end



  describe '#assign_all_hierarchic_custom_fields' do

    let(:fake_issue) { build(:issue) }
    let(:fake_project) { build(:project) }

    context 'entry has an issue and a project' do
      let(:time_entry) { build_stubbed(:time_entry, issue: fake_issue, project: fake_project) }

      before do
        dummy_yaml.keys.each do |name|
          expect(time_entry).to receive(:get_custom_value_from_hierarchy).with(fake_issue, name)
        end
      end

      specify { time_entry.send(:assign_all_hierarchic_custom_fields) }
    end

    context 'entry has only a project' do
      let(:time_entry) { build_stubbed(:time_entry, project: fake_project) }

      before do
        dummy_yaml.keys.each do |name|
          expect(time_entry).to receive(:get_custom_value_from_hierarchy).with(fake_project, name)
        end
      end

      specify { time_entry.send(:assign_all_hierarchic_custom_fields) }
    end

  end

  describe '#assignable_custom_field_value_for' do

    before do
      binding.pry
    end

  end

  describe "#assign_time_entry_custom_field" do
    let(:time_entry) { build(:time_entry, project: root_project, activity_id: root_project.activities.first.id) }

    before do
      time_entry.send(:assign_time_entry_custom_field, 'first_field', 'Hey!')
      time_entry.save
    end

    specify do
      expect(time_entry.custom_values.first.value).to eq('Hey!')
    end
  end

  after do
    ProjectCustomField.delete_all
    TimeEntryCustomField.delete_all
    CustomValue.delete_all
  end

end
