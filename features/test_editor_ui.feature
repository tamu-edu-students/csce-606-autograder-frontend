Feature: Test Editor UI Updates
  As a CSCE 120 organization member
  So that I can more intuitively interact with the test editor
  I want to see more accessible styling, more clear labeling, and confirmation for permanent actions

  Background: Test Editor setup
    Given the following assignments exist:
      | assignment_name | repository_name |
      | assignment1     | assignment1     |
    And I am logged in as an "instructor"
    And I am on the "Assignment Management" page for "assignment1"
    And the following test case groupings exist for "assignment1":
        | grouping_name       |
        | Basic Functionality |
        | Edge Cases          |
    And "<Test Name>" test exists in "<Grouping Name>" in order
        |Test Name              | Grouping Name       |
        |Test_BF_1              | Basic Functionality |
        |Test_EC_1              | Edge Cases          |
    
    Scenario: Display Test Editor in a landscape layout
        Then the Test Editor layout should have a wider landscape view
        And it should not overlap with the right column
        And all fields should be fully visible without cutting off content
    
    Scenario: Adding units to the Timeout field
        Then I should see a label for the "Timeout" field with units in seconds
        And the "Timeout" field should display a placeholder or hint text indicating "seconds"

    Scenario: Confirm deletion of a test case
        When I am on the "Edit_Test" page for "Test_BF_1"
        And I click the "Delete Test" button
        Then I should see a confirmation prompt with the message "Are you sure you want to delete this test?"
        And I confirm the deletion
        Then "Test_BF_1" should no longer appear in the test list

    
