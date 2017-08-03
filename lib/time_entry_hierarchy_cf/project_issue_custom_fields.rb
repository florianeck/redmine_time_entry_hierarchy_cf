module TimeEntryHierarchyCf::ProjectIssueCustomFields
  extend ActiveSupport::Concern

  included do
    before_save :assign_all_hierarchic_custom_fields
  end

  # this will be called recursively if required
  def get_custom_value_from_hierarchy(object, name)
    field_value = assignable_custom_field_value_for(object, name)
    
    # running fallback method
    if field_value.blank?
      field_value = TimeEntryHierarchyCf.get_fallback_value_for(object, name)
    end
    
    # exit condition - avoid stack level to deep
    if object == self.project && object.parent.nil?
      assign_time_entry_custom_field(name, field_value) unless field_value.blank?
      return
    end

    # second exit condition - nothing is found and project tree top is reached
    return if field_value.blank? && object.is_a?(Project) && object.parent.nil?

    if !field_value.blank?
      assign_time_entry_custom_field(name, field_value)
    elsif object.parent.present?
      get_custom_value_from_hierarchy(object.parent, name)
    elsif self.project.present?
      get_custom_value_from_hierarchy(self.project, name)
    end
  end

  def assignable_custom_field_value_for(object, name)
    object.custom_field_values.select {|f| f.custom_field.internal_name ==  TimeEntryHierarchyCf::Naming.internal_name_for(object.class, name) }.first.try(:value)
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

  def assign_time_entry_custom_field(name, value)
    self.custom_field_values.select {|f| f.custom_field.internal_name == TimeEntryHierarchyCf::Naming.internal_name_for(self.class, name)}.first.try("value=", value  )
  end

end