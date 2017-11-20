Redmine::Plugin.register :redmine_time_entry_hierarchy_cf do
  name 'TimeEntry Custom Fields'
  author 'Florian Eck for akquinet'
  description 'Automatically assign custom field values from Issues&Projects to TimeEntry'
  version '1.1'
end

require "time_entry_hierarchy_cf"
require "time_entry_hierarchy_cf/project_issue_custom_fields"

Rails.application.config.after_initialize do
  TimeEntry.send(:include, TimeEntryHierarchyCf::ProjectIssueCustomFields)
end
