Feature: File Selection from Nested Dropdown in Test Form

  Background:
    Given the following assignments exist:
      | assignment_name | repository_name   |
      | assignment1     | assignment-1-repo |
    And I am logged in as an "instructor"
    And I am on the "Assignment Management" page for "assignment1"

  @javascript
  Scenario: Viewing the file selection dropdown
    When I click on "include"
    Then I should see a nested file structure dropdown


