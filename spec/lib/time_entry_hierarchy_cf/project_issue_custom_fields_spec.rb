require File.expand_path("../../../spec_helper", __FILE__)

RSpec.describe TimeEntryHierarchyCf::ProjectIssueCustomFields do

  let!(:dummy_config_path) { File.expand_path("../../../fixtures/spec_config_short.yml", __FILE__) }
  let!(:dummy_yaml)   { YAML::load(File.open(dummy_config_path).read) }

  # CustomFields according to the spec config
  let(:issue_field)      { create(:issue_custom_field,   name: 'Issue Field',          field_format: 'string',  internal_name: 'issue_one_field')}
  let(:project_field)    { create(:project_custom_field, name: 'Project Field',        field_format: 'string',  internal_name: 'project_one_field')}
  let!(:time_entry_field) { create(:time_entry_custom_field,   name: 'TimeEntry Field', field_format: 'string',  internal_name: 'time_entry_one_field')}

  let(:root_project)    { create(:project, name: "my root project", custom_field_values: { project_field.id => "Hello" }) }

  before do
    allow(TimeEntryHierarchyCf).to receive(:yaml_config).and_return(dummy_yaml)
    allow_any_instance_of(Project).to receive(:available_custom_fields).and_return(ProjectCustomField.all)
    allow_any_instance_of(Issue).to receive(:available_custom_fields).and_return(IssueCustomField.all)
  end

  specify "module is included in TimeEntry class" do
    expect(TimeEntry.included_modules).to include(described_class)
  end

  describe '#get_custom_value_from_hierarchy' do

    before do
      time_entry.send(:assign_all_hierarchic_custom_fields)
    end

    context 'with issues' do
      context 'directly associatated issue with value' do
        let(:issue) { create(:issue, subject: "my first issue", project: root_project, custom_field_values: { issue_field.id => "Issue1" } ) }
        let(:time_entry) { build(:time_entry, issue: issue, project: root_project) }

        specify { expect(time_entry.custom_field_values.first.value).to eq("Issue1") }
      end

      context 'sub-issue with value' do
        let(:top_issue) { create(:issue, subject: "my first issue", project: root_project, custom_field_values: { issue_field.id => "TopIssue" } ) }
        let(:sub_issue) { create(:issue, subject: "my second issue", tracker: top_issue.tracker, priority: top_issue.priority, project: root_project, parent: top_issue) }

        let(:time_entry) { build(:time_entry, issue: sub_issue, project: root_project) }
        specify { expect(time_entry.custom_field_values.first.value).to eq("TopIssue") }
      end

      context 'two sub-issues with value' do
        let(:top_issue) { create(:issue, subject: "my first issue", project: root_project, custom_field_values: { issue_field.id => "TopIssue" } ) }
        let(:sub_issue) { create(:issue, subject: "my second issue", tracker: top_issue.tracker, priority: top_issue.priority, project: root_project, parent: top_issue) }
        let(:sub_issue_2) { create(:issue, subject: "my third issue", tracker: top_issue.tracker, priority: top_issue.priority, project: root_project, parent: sub_issue) }

        let(:time_entry) { build(:time_entry, issue: sub_issue_2, project: root_project) }
        specify { expect(time_entry.custom_field_values.first.value).to eq("TopIssue") }
      end
    end

    context 'with project' do
      context 'directly associatated project with value' do
        let(:time_entry) { build(:time_entry, project: root_project) }

        specify { expect(time_entry.custom_field_values.first.value).to eq("Hello") }
      end

      context 'sub-project with value from root project' do
        let(:sub_project) { create(:project, name: "my second project", parent: root_project) }
        let(:time_entry) { build(:time_entry, project: sub_project) }
        specify { expect(time_entry.custom_field_values.first.value).to eq("Hello") }
      end

      context 'projects without value' do
        let(:root_project)    { create(:project, name: "my root project") }
        let(:sub_project)     { create(:project, name: "my second project", parent: root_project) }
        let(:time_entry)      { build(:time_entry, project: sub_project) }

        specify { expect(time_entry.custom_field_values.first.value).to be_blank }
      end
    end

    context 'with project/issue tree' do
      context 'issue without value' do
        let(:issue) { create(:issue, subject: "my first issue", project: root_project) }
        let(:time_entry)      { build(:time_entry, project: root_project, issue: issue) }

        specify { expect(time_entry.custom_field_values.first.value).to eq('Hello') }
      end
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

    context 'value is set for time entry direclty' do
      let(:time_entry) { build(:time_entry, issue: fake_issue, project: fake_project, custom_field_values: {time_entry_field.id => 'Primary'}) }

      before do
        expect(time_entry).to receive(:assign_time_entry_custom_field).with('one_field', 'Primary')
      end
      specify { time_entry.send(:assign_all_hierarchic_custom_fields) }
    end
  end

  describe '#assignable_custom_field_value_for' do
    let(:time_entry) { build_stubbed(:time_entry) }

    specify { expect(time_entry.assignable_custom_field_value_for(root_project, 'one_field')).to eq('Hello') }
  end

  describe "#assign_time_entry_custom_field" do
    let(:root_project)    { create(:project, name: "my root project") }
    let(:time_entry) { build(:time_entry, project: root_project, activity_id: root_project.activities.first.id) }

    before do
      time_entry.send(:assign_time_entry_custom_field, 'one_field', 'Hey!')
      time_entry.save
    end

    specify do
      expect(time_entry.custom_values.last.value).to eq('Hey!')
    end
  end

  after do
    [IssueCustomField,
      ProjectCustomField,
      TimeEntryCustomField,
      CustomValue, Tracker, IssueStatus, IssuePriority
    ].each {|x| x.delete_all }
  end

end
