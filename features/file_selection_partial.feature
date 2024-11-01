Feature: File Selection from Nested Dropdown in Test Form

  Background:
    Given the following assignments exist:
      | assignment_name | repository_name   |
      | assignment1     | assignment-1-repo |
    And I am logged in as an "instructor"
    And I am on the "Assignment Management" page for "assignment1"

  Scenario: Viewing the file selection dropdown
    When I click on "include"
    Then I should see a nested file structure dropdown
    And the dropdown should contain the following structure:
      | Directory   | Subdirectory | File           |
      | tests       |              |                |
      | tests/c++   |              |                |
      | tests/c++   | unit_tests   |                |
      | tests/c++   | integration  |                |
      | tests/c++   | unit_tests   | test_file1.cpp |
      | tests/c++   | unit_tests   | test_file2.cpp |
      | tests/c++   | integration  | test_file3.cpp |

  Scenario: Selecting multiple files from different subdirectories
    When I click on "include"
    And I expand the "tests" directory
    And I expand the "c++" directory
    And I expand the "unit_tests" subdirectory
    And I expand the "integration" subdirectory
    And I select the following files:
      | Directory          | File           |
      | tests/c++/unit_tests | test_file1.cpp |
      | tests/c++/unit_tests | test_file2.cpp |
      | tests/c++/integration | test_file3.cpp |
    Then the include field should display the selected file paths
    And the dropdown should close