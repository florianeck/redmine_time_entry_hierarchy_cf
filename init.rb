Redmine::Plugin.register :time_entry_custom_fields do
  name 'TimeEntry Custom Fields'
  author 'Florian Eck for akquinet'
  description 'Automatically assign custom field valies from Iss'
  version '0.1.0'
end


require "time_entry_hierarchy_cf"
require "time_entry_hierarchy_cf/project_issue_custom_fields"

require "time_entry"
TimeEntry.send(:include, TimeEntryHierarchyCf::ProjectIssueCustomFields)