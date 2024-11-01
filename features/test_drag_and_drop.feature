Feature: The user should be able to move test cards within and in-between groups
  As a CSCE 120 GitHub organization member
  So that I can interact with test case groupings
  I want to be able to move test cards within the same group or in-between different groups
  Background: Assignments in the GitHub organization
    Given the following assignments exist:
        | assignment_name | repository_name   |
        | assignment1     | assignment1 |
        | assignment2     | assignment2 |
        | assignment3     | assignment3 |
    And I am logged in as an "instructor"
    And I am on the "Assignment Management" page for "assignment1"
    And the following test case groupings exist for "assignment1":
        | grouping_name       |
        | Basic Functionality |
        | Edge Cases          |
    And "<Test Name>" test exists in "<Grouping Name>" in order
        |Test Name              | Grouping Name       |
        |Test_BF_1              | Basic Functionality |
        |Test_BF_2              | Basic Functionality |
        # |Test_EC_1              | Edge Cases          |
        # |Test_EC_2              | Edge Cases          |
  Scenario: Move test within the same group
    When I move "Test_BF_1" to after "Test_BF_2" in "Basic Functionality" group
    Then I should see "Test_BF_1" after "Test_BF_2" in "Basic Functionality" group
#   Scenario: Move test in-between groups
#     When I move "Test_BF_1" from "Basic Functionality" group to after "Test_EC_1" in "Edge Cases" group
#     Then I should see "Test_BF_1" after "Test_EC_1" in "Edge Cases" group