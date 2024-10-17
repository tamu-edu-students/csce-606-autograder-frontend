Feature: Update Assignments view

    Background:
    Given the following assignments exist:
        | repository_name   | created_at                          | updated_at                          |
        | assignment-1-repo | 2024-10-03 18:56:13.176651000 +0000 | 2024-10-03 18:56:13.176651000 +0000 |
        | assignment-2-repo | 2024-10-03 18:56:13.176651000 +0000 | 2024-10-03 18:56:13.176651000 +0000 |
        | assignment-3-repo | 2024-10-03 18:56:13.176651000 +0000 | 2024-10-03 18:56:13.176651000 +0000 |


  Scenario: Display assignments in a table
    Given I am on the assignments page
    Then I should see a table displaying assignments with columns for "Repository Name", "Created On", and "Last Updated"

  Scenario: Sort assignments by repo name
    Given I am on the assignments page
    When I click on the "Repo Name" column header
    Then the assignments should be sorted by repo name in ascending order
    And I should see a downward arrow
    When I click on the "Repo Name" column header again
    Then the assignments should be sorted by repo name in descending order
    And I should see a upward arrow

  Scenario: Sort assignments by creation date
    Given I am on the assignments page
    When I click on the "Created On" column header
    Then the assignments should be sorted by creation date in ascending order (oldest to newest)
    And I should see a downward arrow
    When I click on the "Created On" column header again
    Then the assignments should be sorted by creation date in descending order (newest to oldest)
    And I should see a upward arrow

  Scenario: Sort assignments by last updated date
    Given I am on the assignments page
    When I click on the "Last Updated" column header
    Then the assignments should be sorted by last updated date in ascending order (oldest to newest)
    And I should see a downward arrow
    When I click on the "Last Updated" column header again
    Then the assignments should be sorted by last updated date in descending order (newest to oldest)
    And I should see a upward arrow
