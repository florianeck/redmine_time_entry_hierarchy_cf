module TimeEntryHierarchyCf::ProjectIssueCustomFields
  extend ActiveSupport::Concern

  included do
    before_save :assign_all_hierarchic_custom_fields
  end

  # this will be called recursively if required
  def get_custom_value_from_hierarchy(object, field_name)
    field_value = assignable_custom_field_value_for(object, field_name)
    
    # exit condition - avoid stack level to deep
    if object == self.project && object.parent.nil?
      assign_time_entry_custom_field(field_name, field_value) unless field_value.blank?
      return
    end

    # second exit condition - nothing is found and project tree top is reached
    return if field_value.blank? && object.is_a?(Project) && object.parent.nil?

    if !field_value.blank?
      assign_time_entry_custom_field(field_name, field_value)
    elsif object.parent.present?
      get_custom_value_from_hierarchy(object.parent, field_name)
    elsif self.project.present?
      get_custom_value_from_hierarchy(self.project, field_name)
    end
  end
  
  # checking wether the given object (Project / Issue / TimeEntry ) has a custom value for 'field_name' present -
  # else: running fallback method to see if value can be loaded from the instance itself by using `.try` method
  def assignable_custom_field_value_for(object, field_name)
    cf_value = object.custom_field_values.select {|f| f.custom_field.internal_name ==  TimeEntryHierarchyCf::Naming.internal_name_for(object.class, field_name) }.first.try(:value)
    cf_value.presence || TimeEntryHierarchyCf.get_fallback_value_for(object, field_name)
  end

  private

  def assign_all_hierarchic_custom_fields
    TimeEntryHierarchyCf.config_from_yaml.keys.each do |field_name|
      if self.assignable_custom_field_value_for(self, field_name).present?
        assign_time_entry_custom_field(field_name, self.assignable_custom_field_value_for(self, field_name))
      elsif self.issue.present?
        self.get_custom_value_from_hierarchy(self.issue, field_name)
      elsif self.project.present?
        self.get_custom_value_from_hierarchy(self.project, field_name)
      end
    end
  end

  def assign_time_entry_custom_field(field_name, value)
    self.custom_field_values.select {|f| f.custom_field.internal_name == TimeEntryHierarchyCf::Naming.internal_name_for(self.class, field_name)}.first.try("value=", value  )
  end

end