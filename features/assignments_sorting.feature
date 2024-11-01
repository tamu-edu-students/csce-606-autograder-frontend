Feature: Update Assignments view

    Background:
    Given the following assignments with creation time exist:
        | assignment_name | repository_name   | created_at                          | updated_at                          |
        | assignment1     | assignment-1-repo | 2024-10-03 18:56:13.176651000 +0000 | 2024-10-03 18:56:13.176651000 +0000 |
        | assignment2     | assignment-2-repo | 2024-10-03 18:56:13.876651000 +0000 | 2024-10-03 18:56:13.196651000 +0000 |
        | assignment3     | assignment-3-repo | 2024-10-03 18:56:13.976651000 +0000 | 2024-10-03 18:56:13.186651000 +0000 |


  Scenario: Display assignments in a table
    Given I am on the "Assignment" page
    Then I should see a table displaying assignments with columns for "Assignment Name", "Created On", "Last Updated", and "Actions"

  Scenario: Sort assignments by repo name
    Given I am on the "Assignment" page
    Then the assignments should be sorted by "repo name" in "ascending" order
    When I click on the "Assignment Name" column header 
    Then the assignments should be sorted by "repo name" in "descending" order

  Scenario: Sort assignments by creation date
    Given I am on the "Assignment" page
    When I click on the "Created On" column header
    Then the assignments should be sorted by "creation date" in "ascending" order 
    When I click on the "Created On" column header 
    Then the assignments should be sorted by "creation date" in "descending" order

  Scenario: Sort assignments by last updated date
    Given I am on the "Assignment" page
    When I click on the "Last Updated" column header
    Then the assignments should be sorted by "last updated date" in "ascending" order 
    When I click on the "Last Updated" column header 
    Then the assignments should be sorted by "last updated date" in "descending" order