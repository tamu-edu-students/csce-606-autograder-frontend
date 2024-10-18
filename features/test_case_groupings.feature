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

  # Scenario: Create test case without grouping number
  #   When I create a new test case without grouping number
  #   Then I should see the test case in Miscellaneous test group

  # Scenario: Create test case with grouping number
  #   When I create a new test case with existing grouping number
  #   Then I should see the test case in the target test group

  # Scenario: Update test case by grouping number
  #   When I create a new test case with existing grouping number
  #   And I update the test case by changing the grouping number to another existing grouping number
  #   Then I should see the test case in the new test group





  # Scenario: View an existing test case grouping and test cases
  #   When I click on the "Basic Functionality" grouping name
  #   And I should see the list of test cases associated with "Basic Functionality"
  #   When I click on the "test1" test case name
  #   And I should see the test sub-number within grouping and other paras on the right

  # Scenario: Scroll to top button inside test case grouping block
  #   When I scroll down in test case grouping block
  #   And I should see a button named "Scroll to top"
  #   And I click "Scroll to top"
  #   Then I should be taken to the top of the test case groupings block









  # Scenario: Update an existing test case grouping name
  #   Given the "Edge Cases" test case grouping exists
  #   When I click on the "Edit" button next to "Edge Cases"
  #   And I update the "Grouping Name" to "Boundary Tests"
  #   And I click "Save"
  #   Then I should see "Boundary Tests" in the list of test case groupings
  #   And I should see a success message "Test case grouping 'Edge Cases' updated to 'Boundary Tests'"
  
  # Scenario: Prevent duplicate test case grouping names in update
  #   Given the "Basic Functionality" test case grouping exists
  #   When I attempt to update an existing test case grouping with the name "Basic Functionality"
  #   And I click "Submit"
  #   Then I should see an error message "A test case grouping with this name already exists"

  # Scenario: Delete a test case grouping
  #   Given the "Basic Functionality" test case grouping exists
  #   When I click on the "Delete" button next to "Basic Functionality"
  #   And I confirm the deletion
  #   Then I should no longer see "Basic Functionality" in the list of test case groupings
  #   And I should see a message "Test case grouping 'Basic Functionality' deleted successfully"

