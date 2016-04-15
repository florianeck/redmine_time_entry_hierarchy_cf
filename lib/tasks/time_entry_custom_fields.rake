namespace :time_entry_custom_fields do

  desc "Create the custom fields configured in config/time_entry_custom_fields.yml"
  task :create_fields => :environment do
    if TimeEntryCustomFields.config_valid?
      TimeEntryCustomFields.config_from_yaml.keys.each do |type|
        TimeEntryCustomFields.config_from_yaml[type]['fields'].keys.each do |field_name|
          e = TimeEntryCustomFields.create_custom_field!(type, field_name)
          if e.persisted?
            puts "CREATED: #{type} => #{field_name}"
          else
            puts "FAIL: #{type} => #{field_name}\n\t => #{e.errors.messages}"
          end
        end
      end
    end
  end

end