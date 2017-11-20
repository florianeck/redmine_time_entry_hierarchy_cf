namespace :time_entry_hierarchy_cf do

  desc "Create the custom fields configured in config/time_entry_custom_fields.yml"
  task :create_fields => :environment do
    if TimeEntryHierarchyCf.config_valid?
      TimeEntryHierarchyCf.config_from_yaml.keys.each do |type|
        TimeEntryHierarchyCf.config_from_yaml.keys.each do |field_name|
          entries = TimeEntryHierarchyCf.create_custom_field!(field_name)
          entries.each do |model_name, entry|
            if entry.persisted?
              puts "CREATED: #{model_name} => #{entry.internal_name}"
            else
              puts "FAIL: #{model_name} => #{entry.internal_name}\n\t => #{e.errors.messages}"
            end
          end
        end
      end
    end
  end

end