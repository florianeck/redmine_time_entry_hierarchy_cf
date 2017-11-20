# Redmine Plugin: TimeEntryHierarchyFields

## What it does

This plugin automatically copies defined custom fields from issues and projects to created time entries for those entities.
It checks hierarchically (bottom) if a given value exists by the following rules

```
  - Project
    - Subproject
      - Issue
        - Sub-issue
          - Timeentry
```

and takes the first value it finds while working up in the tree.

## Config

List all fields that should be covered by hierarchy custom fields
Each entry creates three fields:
  - 'issue_customer_invoice_reference' as IssueCustomField
  - 'project_customer_invoice_reference' as PrjoectCustomField
  - 'time_entry_customer_invoice_reference' as TimeEntryCustomField

All options given are directly passed to the created time entry.

** INFO: 'internal_name' field is automatically created and MUST NOT be changed/overwritten **

Example entry from the YAML file

```
customer_invoice_reference:
  field_format: string
  searchable: true
  fallbacks:
    issue: 'user.name'
    project: 'issues.first.assigned_to.name'
    time_entry: 'user.name'
```

## Fallbacks

If the given field is not found on th current instance, it is possible to check for other values on the instance instead. This can be done by adding the method (or method chain) 
to be called additionally.

## Info

This Plugin was created by Florian Eck for akquinet GmbH.
It is licensed under GNU GENERAL PUBLIC LICENSE.

It has been tested with EasyRedmine, but should also work for regular Redmine installations. If you find any bugs, please file an issue or create a PR.