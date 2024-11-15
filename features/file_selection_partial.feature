Feature: File Selection from Nested Dropdown in Test Form

  Background:
    Given the following assignments exist:
      | assignment_name | repository_name   | files_to_submit                   |
      | assignment1     | assignment-1-repo | main.cpp\nhelper.cpp\nhelper.h\n  |
    And I am logged in as an "instructor"
    And I am on the "Assignment Management" page for "assignment1"

  @javascript
  Scenario: Viewing the file selection dropdown
    When I click on "include"
    Then I should see a nested file structure dropdown

  @javascript
  Scenario: Selecting multiple files from different subdirectories
    When I click on "include"
    And I expand the "io_tests" directory
    And I select the following files in "include" dropdown:
      | Directory             | File           |
      | tests/c++/io_tests    | input.txt      |
      | tests/c++/io_tests    | output.txt     |
      | tests/c++/io_tests    | readme.txt     |
    Then the include field should display the selected file paths
