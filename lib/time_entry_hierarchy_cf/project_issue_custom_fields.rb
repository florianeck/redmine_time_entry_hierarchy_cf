module TimeEntryHierarchyCf::ProjectIssueCustomFields
  extend ActiveSupport::Concern

  def custom_fields_for(type, name)
    {
      source: ProjectCustomField.find_by_internal_name()
    }
  end

  def assign_custom_field_value_from!(type, name)
    base_object = self.send(type)

    object_field_name     = TimeEntryHierarchyCf::Naming.internal_name_for(type, name)
    time_entry_field_name = TimeEntryHierarchyCf::Naming.time_entry_internal_name_for(type, name)

    # ingnore is object not given
    if base_object

    end
  end

  # this will be called recursively if required
  def get_custom_value_from_object(object, object_field_name)

  end

end