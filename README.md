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
  - 'time_entr_customer_invoice_reference' as TimeEntryCustomField

All options given are directly passed to the created time entry.

** INFO: 'internal_name' field is automatically created and MUST NOT be changed/overwritten **

Example entry from the YAML file

```
customer_invoice_reference:
  field_format: string
  searchable: true
```
