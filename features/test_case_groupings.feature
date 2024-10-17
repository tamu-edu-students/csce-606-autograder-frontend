Feature: Test Case Groupings CRUD
  As a CSCE 120 GitHub organization member
  So that I can interact with test case groupings
  I want to be able to create, view, update, and delete groupings of related test cases

  Background:
    Given I am logged in as a CSCE 120 GitHub organization member
    Given I am on the "Assignment Management" page for "assignment1"
    And the following test case groupings exist:
      | grouping_name       |
      | Basic Functionality |
      | Edge Cases          |

  Scenario: Create a new test case grouping
    When I click on the "Create New Grouping" button
    And I fill in "Grouping Name" with "Performance Tests"
    And I click "Submit"
    Then I should see "Performance Tests" in the list of test case groupings
    And I should see a success message "Test case grouping 'Performance Tests' created successfully"
  
  Scenario: Prevent duplicate test case grouping names in create
    When I attempt to create a new test case grouping with the name "Basic Functionality"
    And I click "Submit"
    Then I should see an error message "A test case grouping with this name already exists"

  Scenario: Create a new test case inside a test case grouping
    When I click on the "Create New Test Case" button
    And I should see the Create test part on the right

  Scenario: View an existing test case grouping and test cases
    When I click on the "Basic Functionality" grouping name
    And I should see the list of test cases associated with "Basic Functionality"
    When I click on the "test1" test case name
    And I should see the test sub-number within grouping and other paras on the right

  Scenario: Scroll to top button inside test case grouping block
    When I scroll down in test case grouping block
    And I should see a button named "Scroll to top"
    And I click "Scroll to top"
    Then I should be taken to the top of the test case groupings block









  Scenario: Update an existing test case grouping name
    Given the "Edge Cases" test case grouping exists
    When I click on the "Edit" button next to "Edge Cases"
    And I update the "Grouping Name" to "Boundary Tests"
    And I click "Save"
    Then I should see "Boundary Tests" in the list of test case groupings
    And I should see a success message "Test case grouping 'Edge Cases' updated to 'Boundary Tests'"
  
  Scenario: Prevent duplicate test case grouping names in update
    Given the "Basic Functionality" test case grouping exists
    When I attempt to update an existing test case grouping with the name "Basic Functionality"
    And I click "Submit"
    Then I should see an error message "A test case grouping with this name already exists"

  Scenario: Delete a test case grouping
    Given the "Basic Functionality" test case grouping exists
    When I click on the "Delete" button next to "Basic Functionality"
    And I confirm the deletion
    Then I should no longer see "Basic Functionality" in the list of test case groupings
    And I should see a message "Test case grouping 'Basic Functionality' deleted successfully"

