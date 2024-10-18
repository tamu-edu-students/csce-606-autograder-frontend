Feature: Test Case Groupings CRUD
  As a CSCE 120 GitHub organization member
  So that I can interact with test case groupings
  I want to be able to create, view, update, and delete groupings of related test cases

  Background: Assignments in the GitHub organization
    Given the following assignments exist:
        | assignment_name | repository_name   |
        | assignment1     | assignment1 |
        | assignment2     | assignment2 |
        | assignment3     | assignment3 |
    Given I am logged in as an "instructor"
    And the following test case groupings exist for "assignment1":
      | grouping_name       |
      | Basic Functionality |
      | Edge Cases          |
    And I am on the "Assignment Management" page for "assignment1"

  Scenario: Default test case grouping Miscellaneous Tests
    Then I should see "Miscellaneous Tests" in the list of test case groupings

  Scenario: Create a new test case grouping with different name
    And I should see a text field at the top of the scrollable block
    And I fill in the text field with "Performance Tests"
    And I click the add button
    Then I should see "Performance Tests" in the list of test case groupings
    And I should see a success message "Test case grouping 'Performance Tests' created successfully"

  Scenario: Create duplicate test case grouping
    And I should see "Basic Functionality" in the list of test case groupings
    And I fill in the text field with "Basic Functionality"
    And I click the add button
    Then I should see an error message "A test case grouping with this name already exists"

  Scenario: Create test case grouping without name
    And I fill in the text field with ""
    And I click the add button
    Then I should see an error message "Test grouping name can't be blank"

  Scenario: Create a new test case inside a test case grouping
    When I click on the "Add new test" link
    Then I should see the "test-form" view

  Scenario: View an existing test case grouping and test cases
    When I click on the "Basic Functionality" grouping
    And I should see the list of test cases associated with "Basic Functionality"
    When I click on the "test1" test case name
    Then I should see the test displayed in the "test-form" view

  Scenario: Delete a test case grouping
    When I click on the "x" button next to "Basic Functionality"
    Then I should no longer see "Basic Functionality" in the list of test case groupings
    And I should see a message "Test grouping was successfully deleted."