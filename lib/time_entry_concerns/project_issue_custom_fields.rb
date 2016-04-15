module TimeEntryConcerns::ProjectIssueCustomFields
  extend ActiveSupport::Concern

  def custom_fields_for(type, name)
    {
      source: ProjectCustomField.find_by_internal_name()
    }
  end

  def assign_custom_field_value_from!(type, name)
    base_object = self.send(type)

    object_field_name     = TimeEntryCustomFields::Naming.internal_name_for(type, name)
    time_entry_field_name = TimeEntryCustomFields::Naming.time_entry_internal_name_for(type, name)

    # ingnore is object not given
    if base_object

    end
  end

end