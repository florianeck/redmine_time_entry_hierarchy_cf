module TimeEntryHierarchyCf::ProjectIssueCustomFields
  extend ActiveSupport::Concern

  included do
    before_save :assign_all_hierarchic_custom_fields
  end


  def custom_fields_data_fields_for(type, name)
    {
      source: TimeEntryHierarchyCf.custom_field_class_for(type).find_by_internal_name(TimeEntryHierarchyCf::Naming.internal_name_for(type, name)),
      dest: TimeEntryCustomField.find_by_internal_name(TimeEntryHierarchyCf::Naming.time_entry_internal_name_for(type, name))
    }
  end

  # this will be called recursively if required
  def get_custom_value_from_object(object, name)
    data_fields = self.custom_fields_data_fields_for(object.class.to_s.downcase, name)

    if object.custom_value_for(data_fields[:source]).present?
      self.custom_value_for(data_fields[:dest]).value = object.custom_value_for(data_fields[:source])
    elsif object.parent && object.parent.custom_value_for(data_fields[:source]).present?
      get_custom_value_from_object(object.parent, name)
    end
  end

  private

  def assign_all_hierarchic_custom_fields

    TimeEntryHierarchyCf.config_from_yaml.each do |type, data|
      data['fields'].keys.each do |name|
        puts "#{type} #{name}"
        self.get_custom_value_from_object(self.send(type), name)
      end
    end

  end

end