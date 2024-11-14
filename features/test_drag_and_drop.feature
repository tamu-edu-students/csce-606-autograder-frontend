Feature: The user should be able to move test cards within and in-between groups
  As a CSCE 120 GitHub organization member
  So that I can interact with test case groupings
  I want to be able to move test cards within the same group or in-between different groups
  Background: Assignments in the GitHub organization
    Given the following assignments exist:
        | assignment_name | repository_name   | files_to_submit                  |
        | assignment1     | assignment1       | main.cpp\nhelper.cpp\nhelper.h\n |
        | assignment2     | assignment2       | main.cpp\nhelper.cpp\nhelper.h\n |
        | assignment3     | assignment3       | main.cpp\nhelper.cpp\nhelper.h\n |
    And I am logged in as an "instructor"
    And I am on the "Assignment Management" page for "assignment1"
    And the following test case groupings exist for "assignment1":
        | grouping_name       |
        | Basic Functionality |
        | Edge Cases          |
    And some tests exist in "Basic Functionality" group in order:
        | test_name   |
        | Test_BF_1   |
        | Test_BF_2   |
        # | Test_EC_1   | Edge Cases          |
        # | Test_EC_2   | Edge Cases          |
    And I am on the "Assignment Management" page for "assignment1"

  @javascript
  Scenario: Move test within the same group
    When I expand the "Basic Functionality" test group
    Then I should see the following tests in "Basic Functionality" group:
        | test_name   |
        | Test_BF_1   |
        | Test_BF_2   |

    When I move "Test_BF_1" to after "Test_BF_2" in "Basic Functionality" group
    And I am on the "Assignment Management" page for "assignment1"
    When I expand the "Basic Functionality" test group
    Then I should see "Test_BF_1" after "Test_BF_2" in "Basic Functionality" group
    And the positions of the tests in "Basic Functionality" group should be updated correctly
#   Scenario: Move test in-between groups
#     When I move "Test_BF_1" from "Basic Functionality" group to after "Test_EC_1" in "Edge Cases" group
#     Then I should see "Test_BF_1" after "Test_EC_1" in "Edge Cases" group