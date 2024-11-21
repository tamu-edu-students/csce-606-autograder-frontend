Feature: Select files for Includes attribute
  As a CSCE 120 GitHub organization member
  So that I can select files for the Includes attribute when dealing with test cases
  I want to select files from a file-tree dropdown with checkboxes for the Includes attribute

  Background: Assignments in the GitHub organization
    Given the following assignments exist:
      | assignment_name | repository_name   | files_to_submit                  |
      | assignment1     | assignment1       | main.cpp\nhelper.cpp\nhelper.h\n |
    And I am logged in as an "instructor"
    And I am on the "Assignment Management" page for "assignment1"
  
  @javascript
  Scenario: Viewing the Includes field as a file-tree dropdown with checkboxes
    When I click on "include"
    And I should see a nested file structure dropdown
    And each file should have a checkbox beside its name

  @javascript
  Scenario: Selecting multiple files for the Includes attribute
    When I click on the Includes file-tree dropdown
    And I expand the "io_tests" directory
    And I select the following files in "include" dropdown:
      | Directory             | File           |
      | tests/c++/io_tests    | input.txt      |
      | tests/c++/io_tests    | output.txt     |
      | tests/c++/io_tests    | readme.txt     |
    Then the "include" field should display the selected file paths

  @javascript
  Scenario: Verifying Include files are correctly saved
    When I create a new test with type "unit"
    And with the name "test-1"
    And with the points "1"
    And with the target "main.cpp"
    And I add the "unit" dynamic text block field
    And I click on the Includes file-tree dropdown
    And I select the following files in "include" dropdown:
      | Directory             | File           |
      | tests/c++/io_tests    | output.txt     |
      | tests/c++/io_tests    | input.txt      |
    And I click the "Create Test" button
    Then I should see a message saying "Test was successfully created"
    And the Includes attribute for "test-1" should be saved as a list of selected file paths